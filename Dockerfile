# --- 第一階段：編譯 (Build Stage) ---
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
WORKDIR /app

# 複製 csproj 並進行還原 (Restore)，利用 Docker 層快取優化速度
COPY *.sln ./
COPY cicd/*.csproj ./cicd/
RUN dotnet restore

# 複製其餘所有原始碼並編譯
COPY . ./
RUN dotnet publish cicd/cicd.csproj -c Release -o out

# --- 第二階段：執行 (Runtime Stage) ---
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

# 從編譯階段複製編譯好的成品 (out 目錄)
COPY --from=build-env /app/out .

# 設定環境變數（可選）
ENV ASPNETCORE_URLS=http://+:80

# 啟動程式 (假設你的專案名稱是 cicd.dll)
ENTRYPOINT ["dotnet", "cicd.dll"]