## Marking script for EuroSkills 2023 Skill39 - Module B

### Preqrequisites
* Machines have OpenSSH installed and administrative public key added
* SSH private key is at `C:\Marking\moduleb`. Alternatively Get-AspectResult `$SshKey` variable default value can be modified

### Execute

Run all tests:
```
PS > ModuleB.ps1
```

Run specific Sub Criterion tests:
```
PS > ModuleB.ps1 -Aspect B2
PS > ModuleB.ps1 -Aspect B4
```

Run specific Aspect test:
```
PS > ModuleB.ps1 -Aspect B3.M1
PS > ModuleB.ps1 -Aspect B5.J1
```

AD users import checker:
```
PS > ADUserChecker.ps1 -Domain dk.skill39.wse -CsvFilePath ".\ES2023_TP39_ModuleB_Users.csv"
```

Encrypt and Decrypt files:
```
# Encrypt
PS > EncryptDecryptFile.ps1 -FilePath .\ModuleB.ps1 -Password "EuroSkills2023" -Action encrypt

# Decrypt
PS > EncryptDecryptFile.ps1 -FilePath .\ModuleB.ps1.encrypted -Password "EuroSkills2023" -Action decrypt
```