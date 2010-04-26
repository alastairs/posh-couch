cls
Filter ConvertTo-JSON {
    Function New-JSONProperty ($name, $value) {
@"
    "$name": $value
"@
    }

    $targetObject = $_
    $jsonProperties = @()
    $properties = $_ | Get-Member -MemberType *property

    ForEach ($property in $properties) {
        #"$($property.Name)=$($targetObject.$($property.Name)) [$($($targetObject.$($property.Name)).GetType())]"
        #(($targetObject.($property.Name)).GetType()).Name

        $value = $targetObject.($property.Name)
        $dataType = (($targetObject.($property.Name)).GetType()).Name

        switch -regex ($dataType) {
            'String'  {$jsonProperties += New-JSONProperty $property.Name "`"$value`""}
            'Int32|Double' {$jsonProperties += New-JSONProperty $property.Name $value}
            'Object\[\]' {
                #$jsonProperties += "`t`"$($property.Name)`": [$($($targetObject.($property.Name)) -join ',')]"
                $str = "`t`"$($property.Name)`": ["
                
                $count = $targetObject.($property.Name).Count
                For($idx=0; $idx -lt $count; $idx++) {
                    $v = $targetObject.($property.Name)[$idx]
                    
                    switch -regex ($v.GetType()) {
                        'String' {$v="`"$v`""}
                    }
                    
                    if($idx+1 -lt $count) {
                        $comma = ","
                    } else {
                        $comma = ""
                    }
                    
                    $str += "$v$($comma)"
                }
                
                
                $jsonProperties += "$str]"
            }
            default {$_}
        }
    }

    "{`r`n $($jsonProperties -join ",`r`n") `r`n}"
}

# Simple test for the convert

(new-object PSObject |
    add-member -pass noteproperty Name 'John Doe' |
    add-member -pass noteproperty Age 10          |
    add-member -pass noteproperty Amount 10.1     |
    add-member -pass noteproperty MixedItems (1,2,3,"a") |
    add-member -pass noteproperty NumericItems (1,2,3) |
    add-member -pass noteproperty StringItems ("a","b","c")
) | ConvertTo-JSON
