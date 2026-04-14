#!/bin/bash
# 测试基金API - 基金代码 011011

echo "=========================================="
echo "测试基金 011011 - 搜索和估值功能"
echo "=========================================="
echo ""

# 测试1: 搜索基金
echo "1. 测试搜索功能 - 搜索关键词: 011011"
echo "------------------------------------------"
curl -s "https://fundsuggest.eastmoney.com/FundSearch/api/FundSearchAPI.ashx?m=1&key=011011"
echo ""
echo ""

# 测试2: 获取基金实时估值
echo "2. 测试实时估值功能 - 基金代码: 011011"
echo "------------------------------------------"
curl -s "http://fundgz.1234567.com.cn/js/011011.js"
echo ""
echo ""

# 测试3: 搜索基金名称（如果知道的话）
echo "3. 测试搜索功能 - 搜索关键词: 博时"
echo "------------------------------------------"
curl -s "https://fundsuggest.eastmoney.com/FundSearch/api/FundSearchAPI.ashx?m=1&key=博时"
echo ""
echo ""

echo "=========================================="
echo "测试完成"
echo "=========================================="
