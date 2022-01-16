function ConvertFrom-XML
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline)]
		[System.Xml.XmlNode]$node
	)
	process
	{   
		$outHash = [ordered] @{ }

		if($node.Attributes -ne $null) 
		{
			$node.Attributes | %{$outHash.$($_.FirstChild.parentNode.LocalName) = $_.FirstChild.value}
		}

		$node.ChildNodes | Group-Object -Property LocalName | ?{ $_.count -gt 1 } | select Name | %{$outHash.($_.Name) = @()}

		foreach($child in $node.ChildNodes)
		{
			$childName = $child.LocalName

			if($child -is [system.xml.xmltext])
			{
				$outHash.$childname += $child.InnerText
			}
			elseif($child.FirstChild.Name -eq '#text' -and $child.ChildNodes.Count -eq 1)
			{
				if($child.Attributes -ne $null)
				{
					$attributeHash = [ordered]@{ }

					$child.Attributes | %{$attributeHash.$($_.FirstChild.parentNode.LocalName) = $_.FirstChild.value}

					$attributeHash.'#text' += $child.'#text'
					$outHash.$childname += $attributeHash
				}
				else
				{ 
					$outHash.$childname += $child.FirstChild.InnerText
				}
			}
			elseif($child.'#cdata-section' -ne $null)
			{
				$outHash.$childname = $child.'#cdata-section'
			}
			elseif($child.ChildNodes.Count -gt 1 -and ($child | gm -MemberType Property).Count -eq 1)
			{
				$outHash.$childname = @()
				foreach($grandchild in $child.ChildNodes)
				{
					$outHash.$childname += (ConvertFrom-XML $grandchild)
				}
			}
			else
			{
				$outHash.$childname += (ConvertFrom-XML $child)
			}
		}
		$outHash
	}
}

[xml]$XML = Get-Content "C:\Users\MY-PC\Downloads\books.xml.txt"
$XML | ConvertFrom-Xml | ConvertTo-Json -Depth 5
