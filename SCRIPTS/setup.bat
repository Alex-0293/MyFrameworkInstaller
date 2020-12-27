$Global:MyFrameworkBootstrapperIRI = ""
Set-ExecutionPolicy RemoteSigned -Scope Process
$MyFrameworkBootstrapper = Invoke-WebRequest -UseBasicParsing $Global:MyFrameworkBootstrapperIRI
Invoke-Expression $MyFrameworkBootstrapper