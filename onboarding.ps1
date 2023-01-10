param(
    ## Dit zorgt ervoor dat er een parameter meegeven kan worden voor het CSV-bestand
     [Parameter()]
     [ValidateNotNullOrEmpty()]
     [string]$CsvFilePath
 )

 ## Deze functie leest alle 'gebruikers' op de lijst en maakt het mogelijk om parameters te kunnen gebruiken
 function Read-Employee {
	[CmdletBinding()]
	param
	(
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$CsvFilePath = $CsvFilePath
	)

	Import-Csv -Path $CsvFilePath
 }

 function New-CompanyAdUser {
    [CmdletBinding()]
	param
	(
		## Dit zorgt ervoor dat er altijd een parameter meegegeven wordt zodat er geen lege users worden aangemaakt
        [Parameter(Mandatory)]
        ## Leest het CSV script en kijkt of deze inhoud bevat
		[ValidateNotNullOrEmpty()]
		## Maakt een object van het CSV-bestand
		[pscustomobject]$UserList
	)

	## Zorgt ervoor de de System.Web module gebruikt kan worden
	Add-Type -AssemblyName System.Web
	## Hier wordt een willekeurig wachtwoord gegenereerd
	$password = [System.Web.Security.Membership]::GeneratePassword((Get-Random -Minimum 20 -Maximum 32), 3)
	$secPw = ConvertTo-SecureString -String $password -AsPlainText -Force

	## Opgegeven naar wordt verkort naar initialen en achternaam
	$userName = "$($UserList.FirstName.Substring(0,1))$($UserList.LastName)"

	## Maakt de gebruiker aan
	$NewUserParameters = @{
		GivenName       = $UserList.FirstName
		Surname         = $UserList.LastName
		Name            = $userName
		AccountPassword = $secPw
	}
	New-AdUser @NewUserParameters

	## Voegt de gebruiker toe aan de groep naar functie
	Add-AdGroupMember -Identity $UserList.Department -Members $userName
 }
 
 ## Dit zorgt ervoor dat de functie van een gebruiker toevoegen wordt uitgevoerd en voor elke 'werknemer' wordt uitgevoerd
 $functions = 'New-CompanyAdUser'
 foreach ($employee in (Read-Employee)) {
     foreach ($function in $functions) {
         & $function -UserList $employee
     }
 }