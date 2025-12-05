# إعداد Deep Linking - فتح التطبيق من الروابط

## الملفات المطلوبة على السيرفر

### 1. ملف Android Asset Links
**المسار:** `https://hagz.app/.well-known/assetlinks.json`

**المحتوى:**
```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.example.hagz",
    "sha256_cert_fingerprints": [
      "SHA256_FINGERPRINT_HERE"
    ]
  }
}]
```

**للحصول على SHA256 Fingerprint:**
```bash
keytool -list -v -keystore android/app/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### 2. ملف iOS App Site Association
**المسار:** `https://hagz.app/.well-known/apple-app-site-association`

**المحتوى:**
```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.example.hagz",
        "paths": ["/doctor/*"]
      }
    ]
  }
}
```

### 3. صفحة Redirect (اختياري)
**المسار:** `https://hagz.app/doctor/{doctorId}`

**المحتوى (HTML مع JavaScript):**
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>فتح التطبيق</title>
</head>
<body>
    <script>
        // محاولة فتح التطبيق
        window.location.href = 'hagz://doctor/{doctorId}';
        
        // إذا فشل، إعادة التوجيه بعد ثانية
        setTimeout(function() {
            window.location.href = 'https://play.google.com/store/apps/details?id=com.example.hagz';
        }, 1000);
    </script>
    <p>جاري فتح التطبيق...</p>
</body>
</html>
```

## ملاحظات مهمة

1. يجب أن يكون الملف `assetlinks.json` متاحاً بدون redirect
2. يجب أن يكون Content-Type: `application/json`
3. يجب أن يكون HTTPS (ليس HTTP)
4. يجب أن يكون الملف بدون extension في بعض الحالات

