# --- 第一階段：編譯 (Build Stage) ---
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
WORKDIR /app

# 先複製全部內容，確保連同子資料夾的專案檔都進去
COPY . .

# 如果你的 .sln 在根目錄，這樣跑絕對沒問題
RUN dotnet restore

RUN dotnet publish -c Release -o out

# --- 第二階段：執行 (Runtime Stage) ---
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

# 從編譯階段複製編譯好的成品 (out 目錄)
COPY --from=build-env /app/out .

# 設定環境變數（可選）
ENV ASPNETCORE_URLS=http://+:80

# 啟動程式 (假設你的專案名稱是 cicd.dll)
ENTRYPOINT ["dotnet", "cicd.dll"]