function ConvertTo-PrettyXML # Function to convert XML output to Indented XML
{
    [cmdletbinding()]
    Param
    (
        [Parameter(ValueFromPipeline,Mandatory=$true)]
        [xml] $XML
    )
    $stringWriter = New-Object System.Io.Stringwriter
    $xmlTextWriter = New-Object System.Xml.xmlTextWriter($stringWriter)
    $xmlTextWriter.Formatting = [System.Xml.Formatting]::Indented
    $XML.WriteContentTo($xmlTextWriter)
    return $stringWriter.ToString()
}
