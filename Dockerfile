# Use Microsoft's ASP.NET 4.8 base image (already includes IIS & ASP.NET 4.8 pre-configured)
FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-ltsc2022

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# 1. Set working directory to IIS default root
WORKDIR /inetpub/wwwroot

# 2. Clean default IIS static landing pages (iisstart.htm, iisstart.png, etc.)
RUN Remove-Item C:\inetpub\wwwroot\* -Recurse -Force

# 3. Copy ONLY essential application files into the web root
COPY web.config .
COPY Start.aspx .

# 4. Set NTFS permissions so IIS worker processes (IIS_IUSRS / IUSR) can write to webroot
RUN $acl = Get-Acl 'C:\inetpub\wwwroot'; \
    $rule1 = New-Object System.Security.AccessControl.FileSystemAccessRule('BUILTIN\IIS_IUSRS', 'FullControl', 'ContainerInherit, ObjectInherit', 'None', 'Allow'); \
    $rule2 = New-Object System.Security.AccessControl.FileSystemAccessRule('NT AUTHORITY\IUSR', 'FullControl', 'ContainerInherit, ObjectInherit', 'None', 'Allow'); \
    $acl.SetAccessRule($rule1); \
    $acl.SetAccessRule($rule2); \
    Set-Acl 'C:\inetpub\wwwroot' $acl

# Expose standard web traffic ports
EXPOSE 80
EXPOSE 443