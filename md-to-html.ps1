param([string]$directory = $(throw 'A directory path must be specified.'))

# Check if the directory exists
if (!(Test-Path $directory)) {
    Write-Error "The directory specified does not exist."
    return
}

# Get a list of all markdown files in the directory
$mdFiles = Get-ChildItem $directory -Filter *.md

# Check if there are any markdown files in the directory
if ($mdFiles.Length -eq 0) {
    Write-Error "There are no markdown files in the directory specified."
    return
}

# Load the contents of the template file
$template = Get-Content "$directory\template.html" -Raw

# Loop through each markdown file
foreach ($mdFile in $mdFiles) {
    # Convert the markdown file to HTML
    Push-Location $mdFile.Directory
    $html = pandoc --embed-resources -f markdown-smart -t html "$($mdFile.BaseName).md"
    Pop-Location

    # Replace the $CONTENTS placeholder in the template with the generated HTML
    $output = $template -replace '\$CONTENTS', $html

    # Save the output to an HTML file in the same directory as the markdown file
    Set-Content -Path "$($mdFile.Directory)\$($mdFile.BaseName).html" -Value $output
}

Move-Item -Force ./$directory/*.html .
Move-Item -Force ./template.html ./$directory/template.html
