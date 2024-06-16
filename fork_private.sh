#!/bin/bash

# 使用命令行参数传入变量
SOURCE_REPO_URL=$1
TARGET_REPO_URL=$2
#COMMIT_MESSAGE=$3

# 检查是否提供了所有必要的参数
if [ -z "$SOURCE_REPO_URL" ] || [ -z "$TARGET_REPO_URL" ]; then
  echo "使用方法: $0 <fork的仓库地址> <自己的仓库地址> "
  exit 1
fi

# 克隆源仓库
git clone "$SOURCE_REPO_URL"

# 获取源仓库的目录名
SOURCE_REPO_DIR=$(basename "$SOURCE_REPO_URL" .git)

# 进入克隆的仓库目录
cd "$SOURCE_REPO_DIR"

# 初始化新的Git仓库
git init

# 移除已存在的远程仓库（如果存在）
git remote remove origin

# 添加新的远程仓库
git remote add origin "$TARGET_REPO_URL"

# 如果提供了提交消息，则创建一个新的提交
# if [ -n "$COMMIT_MESSAGE" ]; then
#   git add .
#   git commit -m "$COMMIT_MESSAGE"
# fi

# 获取当前分支名
CURRENT_BRANCH=$(git branch --show-current)

# 推送当前分支到新的私有仓库
git push -u origin "$CURRENT_BRANCH"

# 提示完成
echo "Repository migration completed!"
