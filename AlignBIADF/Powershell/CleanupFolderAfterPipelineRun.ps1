#clean up the creds
Remove-Item -Recurse -Force  "$($env:userprofile)\.Azure" -ErrorAction SilentlyContinue