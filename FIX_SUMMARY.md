# tg11_block.jmx 500错误修复总结

## 问题描述
tg11_block接口返回HTTP 500 Internal Server Error

## 根本原因分析

### 1. **路径问题**
- tg11_block.jmx使用硬编码路径: `/Users/a58/Documents/文稿 - Xuhao的MacBook Pro/frontend-master/jmeter-api-project/data/auth_data.properties`
- 实际项目位置: `/Users/a58/Downloads/apitest/jmeter-api-project/`
- 导致无法读取认证数据文件

### 2. **Content-Type不匹配**
- JMeter使用: `${__P(CONTENT_TYPE)}` = `application/x-www-form-urlencoded`
- API期望: `application/json`
- 导致服务器无法正确解析JSON请求体

### 3. **Cookie不完整**
- 缺少关键认证Cookie
- Properties文件中冒号被转义，读取时可能出问题

### 4. **CSV格式不匹配**
- CSV DataSet期望14个字段，实际只有10个字段
- 导致变量读取错误

## 修复方案

### 1. 修复认证数据文件路径（动态定位）
```groovy
import org.apache.jmeter.services.FileServer

// 动态定位项目根目录
File baseDir = new File(FileServer.getFileServer().getBaseDir())
File projectRoot = baseDir
int hops = 0
while (hops < 6 && projectRoot != null && !new File(projectRoot, "data").exists()) {
  if (projectRoot.name == "jmeter-api-project") break
  projectRoot = projectRoot.getParentFile()
  hops++
}
if (projectRoot == null) projectRoot = baseDir

// 加载认证数据
def authDataFile = new File(projectRoot, "data/auth_data.properties")
```

### 2. 添加CONTENT_TYPE_JSON配置
**文件**: `config/webbff.env.properties`
```properties
CONTENT_TYPE_JSON=application/json
```

**文件**: `testcases/web-bff/tg11_block.jmx`
```xml
<elementProp name="Content-Type" elementType="Header">
  <stringProp name="Header.name">Content-Type</stringProp>
  <stringProp name="Header.value">${__P(CONTENT_TYPE_JSON)}</stringProp>
</elementProp>
```

### 3. 创建完整的认证数据文件
从工作的curl请求中提取所有必要Cookie，创建正确的auth_data.properties文件：
```properties
GTSELLERSESSIONID=node01it72apw2k88j8e23eodkdsco18020302.node0
gt_p=id:NGRhNmNmNjUtODA2YS00NGYzLTkzYWEtYjVjNzljOTdhNWYz
gt_s=sc:MjU0OQ==|clicksource_featured:...
gt_tm=7af59c5d-718e-494f-bb46-6840dc73f0cb
gt_rememberMe=L4ZfzuIZWgV31mDnNvUPwAuT2IE5zzmw+...
gt_mc=rcd:MA==|nuc:MA==
conversationsToken=s%3AeyJjdHkiOiJKV1QiLCJlbmMiOi...
waap_id=NLD5zw3FA7v+gxpdZInqUCiamzv8eK...
gt_userPref=lfsk:aGlyZSt0ZXNsYSttb2Rl...
gt_bff_ab2=67
gt_gb_exp_uid=9abedb9e-220e-4de3-9513-413e2bccea28
gt_userType=STANDARD
gt_userIntr=cnt:Mg==
gt_appBanner=expiryDate:RnJpLCAyNCBPY3Q...
```

### 4. 禁用不兼容的CSV DataSet
将CSV DataSet的enabled属性改为false，完全依赖动态认证数据加载

### 5. 更新User-Agent和sec-ch-ua
匹配curl请求中的浏览器版本：
```properties
USER_AGENT=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36
SEC_CH_UA="Google Chrome";v="141", "Not?A_Brand";v="8", "Chromium";v="141"
```

### 6. 更新Cookie优先级列表
```groovy
def priorityCookies = [
  'gt_p', 'gt_s', 'GTSELLERSESSIONID', 'gt_tm', 
  'conversationsToken', 'gt_rememberMe', 'gt_mc',
  'gt_userPref', 'waap_id', 'gt_bff_ab2', 'gt_gb_exp_uid',
  'gt_userType', 'gt_userIntr', 'gt_appBanner'
]
```

### 7. 同步修复tg1登录测试
更新tg1_login_via_form.jmx中的路径，使用相同的动态定位逻辑

## 测试验证结果

### 测试命令
```bash
cd /Users/a58/Downloads/apitest/jmeter-api-project
jmeter -n -t testcases/web-bff/tg11_block.jmx -p config/webbff.env.properties
```

### 测试结果
```
✅ block user: 200 OK (Success: true)
✅ unblock user: 200 OK (Success: true)
```

### 关键日志
```
✓ 成功加载认证数据，Cookie字符串长度: 2759
包含的认证字段: 14 个
✓ 找到有效认证信息
认证状态: AUTHENTICATED
```

## 修复的文件清单

1. `/Users/a58/Downloads/apitest/jmeter-api-project/config/webbff.env.properties`
   - 添加 CONTENT_TYPE_JSON
   - 更新 USER_AGENT 到 Chrome 141
   - 更新 SEC_CH_UA 到 Chrome 141

2. `/Users/a58/Downloads/apitest/jmeter-api-project/testcases/web-bff/tg11_block.jmx`
   - 修复硬编码路径为动态路径
   - 更改Content-Type为CONTENT_TYPE_JSON
   - 禁用CSV DataSet
   - 更新Cookie优先级列表

3. `/Users/a58/Downloads/apitest/jmeter-api-project/testcases/web-bff/tg1_login_via_form.jmx`
   - 修复硬编码路径为动态路径

4. `/Users/a58/Downloads/apitest/jmeter-api-project/data/auth_data.properties`
   - 从工作的curl请求中提取完整Cookie数据
   - 正确转义Properties格式

## 关键修复点

1. ✅ **Content-Type**: `application/json`
2. ✅ **认证数据文件路径**: 动态定位
3. ✅ **完整Cookie**: 包含所有14个必要认证字段
4. ✅ **浏览器版本**: Chrome 141
5. ✅ **Properties格式**: 正确转义

## 后续建议

1. 将所有测试用例的硬编码路径改为动态路径
2. 建议使用环境变量或配置文件管理路径
3. 定期更新认证数据（建议在每次测试前运行tg1登录）
4. 考虑添加认证数据过期检查和自动刷新机制

## 总结

通过系统化排查和修复认证路径、Content-Type、Cookie完整性等问题，成功将tg11_block接口从HTTP 500错误修复为200成功响应。所有修改已经过实际测试验证。

