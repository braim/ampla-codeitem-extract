$settings = New-Object System.Xml.XmlReaderSettings
$encoding = New-Object System.Text.UTF8Encoding true # UTF-8 with Byte Order Mark

foreach ($doc in $args)
{
    $file = (Resolve-Path $doc).ProviderPath | Get-Item
    $reader = [System.Xml.XmlReader]::create($file, $settings)
    $pathnames = New-Object System.Collections.Generic.Stack[string]

    while ($reader.Read())
    {
        if ($reader.NodeType -eq [Xml.XmlNodeType]::Element)
        {
            if ($reader.Name -eq "Ampla")
            {
                $pathnames.Push($file.BaseName)
            }
            elseif ($reader.Name -eq "Item")
            {
                if ($reader.GetAttribute("type") -eq "Citect.Ampla.StandardItems.Code")
                {
                    # We've found a code item. Time to extract the contents.
                    # Step 1: Set the file name
                    $pathnames.Push($reader.GetAttribute("name")+'.cs')
                    
                    # Step 2: Locate the descendant Property named Source
                    $reader.ReadToDescendant("Property")
                    do
                    {
                        if ($reader.GetAttribute("name") -eq "Source")
                        {
                            # Step 3:
                            # Write out a CS file, with location based on the Ampla directory path
                            $pathelements = $pathnames.ToArray()
                            [Array]::Reverse($pathelements)
                            $path = $pathelements -join "\"

                            New-Item -Path $path -ItemType file -Force

                            # The file contents are written using [Io.File]::WriteAllText
                            # because New-Item -Value doesn't allow me to set the encoding to UTF-8 with BOM
                            # and Set-Content and Out-File both add an extra new line to the end of each string
                            # which is passed as input (to enable easy writing of string arrays to multi-line text files).
                            # This would screw up the source control by marking unchanged files as modified due to
                            # the encoding changes or extra lines.
                            [Io.File]::WriteAllText($path, $reader.ReadElementString().Replace("`n","`r`n"), $encoding)
                            break
                        }
                    } while ($reader.ReadToNextSibling("Property"))
                }
                else # Keep track of the item nesting in the XML file
                {
                    $pathnames.Push($reader.GetAttribute("name"))
                }
            }
            else # not interested in References, Properties, or anything else
            {
                $reader.Skip()
            }
        }
        elseif ($reader.NodeType -eq [Xml.XmlNodeType]::EndElement)
        {
            [void]$pathnames.Pop()
        }
    }
    $reader.close()
}