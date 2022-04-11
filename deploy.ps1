function ContentsReplace
{
    param
    (
        $taregetFileName,
        [System.Collections.Generic.Dictionary[String, String]]$targetReplaceDic
    )
    $path = $pwd.Path
    $path = $path + '\' + ${taregetFileName}
    Write-Host $path
    $contents = Get-Content -Path $path -Raw -Encoding utf8
    foreach ($item in $targetReplaceDic.GetEnumerator()) 
    {
        $contents = $contents.Replace($item.Key, $item.Value)
    }
    $path = $pwd.Path
    $path = $path + '\' + "after_${taregetFileName}"
    Write-Host $path
    [void](Set-Content -Value $contents -Encoding utf8 -Path $path)
    return $true
}

set-variable -name TENANT_ID "xxxxxxxxxxxxxxxx" -option constant
set-variable -name SUBSCRIPTOIN_GUID "xxxxxxxxxxxxxxxxx" -option constant
set-variable -name BICEP_FILE "main.bicep" -option constant
set-variable -name CONTAINER_NAME "dl2" -option constant
set-variable -name SAMPLE_SOURCE "https://miscstrage.blob.core.windows.net/box/sample.zip?sv=2020-04-08&st=2021-07-29T22%3A21%3A54Z&se=2022-06-30T14%3A59%3A00Z&sr=b&sp=r&sig=TzZxkOsM2BmLH1ImbFy%2FWdWvTNOvU6MDpgEtubEAQ4w%3D"

$parameterFile = "azuredeploy.parameters.dev.json"
$resourceGroupName = "rgxxxx"
$location = "japaneast"

Connect-AzAccount -Tenant ${TENANT_ID} -Subscription ${SUBSCRIPTOIN_GUID} -UseDeviceAuthentication

New-AzResourceGroup -Name ${resourceGroupName} -Location ${location} -Verbose

$deployment = `
(New-AzResourceGroupDeployment `
    -Name devenvironment `
    -ResourceGroupName ${resourceGroupName} `
    -TemplateFile ${BICEP_FILE} `
    -TemplateParameterFile ${parameterFile} `
    -location $location `
    -Verbose)
$resourceSuffix = $deployment.Outputs.resourceSuffix.Value
$storageAccountName = "storage${resourceSuffix}"
$synapesName = "synapse${resourceSuffix}"
#1.作成されたストレージアカウントのSAS TOKEN を取得
  
$ctx = New-AzStorageContext `
    -StorageAccountName $storageAccountName `
    -UseConnectedAccount

$sas = New-AzStorageContainerSASToken -Context $ctx `
    -Name ${CONTAINER_NAME} `
    -Permission rw `
    -ExpiryTime (Get-Date).AddDays(1.0)

$sasurl = ${ctx}.BlobEndPoint + "dl2" + ${sas}
#2.使った sample.zip のダウンロード
invoke-webrequest -uri ${SAMPLE_SOURCE} -outfile sample.zip

#3. zip の解凍(コマンド)
#unzip -d sample sample.zip
Expand-Archive -LiteralPath .\sample.zip -DestinationPath sample

#4. 1で作成したsas token と共に、az copyで 作成されたストレージアカウントのコンテナdl2 へアップロード
azcopy copy "./sample" --recursive=true "${sasurl}" 

Remove-Item -Path sample.zip -Force
Remove-Item -Path .\sample\* -Recurse

#5.作成されたストレージアカウントのアカウントキーを取得
$saKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName).Value[0]

#6-1. create_external_table.sqlの<storage account name>を置換
$inputFilePath = "create_external_table.sql"
$replaceStringsDic = [System.Collections.Generic.Dictionary[String, String]]::new()
$replaceStringsDic.Add("<storage account name>", $storage.StorageAccountName)
$replaceStringsDic.Add("<storage account key>", $saKey)
ContentsReplace -taregetFileName $inputFilePath -targetReplaceDic $replaceStringsDic

#7.Set-AzSynapseSqlScriptをつかって、リポジトリのSQLファイルを一式(*.sql)アップロード
Set-AzSynapseSqlScript -WorkspaceName $synapesName -Name "create_external_table" -DefinitionFile ".\after_create_external_table.sql"

#8. *.ipynbの_storage_account_をストレージアカウント名で置換
$linked_service = Get-AzSynapseLinkedService -WorkspaceName $synapesName

$replaceStringsDic = [System.Collections.Generic.Dictionary[String, String]]::new()
$replaceStringsDic.Add("_storage_account_", $storageAccountName)
$replaceStringsDic.Add("_linked_service_name_", $linked_service.Name[0])
ContentsReplace -taregetFileName "transform-csv.ipynb" -targetReplaceDic $replaceStringsDic
ContentsReplace -taregetFileName "generate_dummies.ipynb" -targetReplaceDic $replaceStringsDic

#9.Set-AzSynapseNotebookをつかって、リポジトリのipynbファイルを一式(*.ipynb)アップロード
Set-AzSynapseNotebook -WorkspaceName $synapesName -Name "transform-csv" -DefinitionFile ".\after_transform-csv.ipynb"
Set-AzSynapseNotebook -WorkspaceName $synapesName -Name "generate_dummies.ipynb" -DefinitionFile ".\after_generate_dummies.ipynb"

#10.ctasのアップロード
Set-AzSynapseSqlScript -WorkspaceName $synapesName -Name "ctas" -DefinitionFile ".\ctas.sql"
