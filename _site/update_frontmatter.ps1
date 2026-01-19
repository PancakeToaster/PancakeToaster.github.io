Get-ChildItem "chapter-*.md" | ForEach-Object {
    $name = $_.Name
    if ($name -match "chapter-(\d+)-(.*)\.md") {
        $num = [int]$matches[1]
        $title = $matches[2] -replace "-", " "
        $content = Get-Content $_.FullName -Raw
        if (-not ($content -match "^---")) {
            $header = "---`r`nlayout: default`r`ntitle: `"Chapter $num: $title`"`r`nnav_order: $($num + 1)`r`n---`r`n`r`n"
            $newContent = $header + $content
            Set-Content $_.FullName -Value $newContent -Encoding UTF8
            Write-Host "Updated $name"
        }
    }
}

Get-ChildItem "appendix-*.md" | ForEach-Object {
    $name = $_.Name
    if ($name -match "appendix-([A-Z])-(.*)\.md") {
        $letter = $matches[1]
        $title = $matches[2] -replace "-", " "
        $content = Get-Content $_.FullName -Raw
        if (-not ($content -match "^---")) {
            $nav = 90 + [byte][char]$letter
            $header = "---`r`nlayout: default`r`ntitle: `"Appendix $letter: $title`"`r`nnav_order: $nav`r`n---`r`n`r`n"
            $newContent = $header + $content
            Set-Content $_.FullName -Value $newContent -Encoding UTF8
            Write-Host "Updated $name"
        }
    }
}
