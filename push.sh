#!/bin/bash

echo "🚀 初始化 Git 仓库..."
git init

echo "📦 添加所有文件..."
git add .

echo "📝 提交代码..."
git commit -m "Initial commit - batch 1"

echo "🔗 设置远程仓库..."
git remote remove origin 2>/dev/null
git remote add origin https://github.com/uwyceee110/global-payments.git

echo "⬆️ 推送到 GitHub..."
git branch -M main
git push -u origin main

echo "🎉 完成！批次 1 已推送到 GitHub。"
