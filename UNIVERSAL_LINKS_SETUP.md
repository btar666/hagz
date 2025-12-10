# إعداد Universal Links - فتح التطبيق من الروابط (مثل Facebook)

## ✅ الكود جاهز في التطبيق

الكود في التطبيق مهيأ بشكل كامل لـ Universal Links. الرابط `https://hagz.app/doctor/{doctorId}` سيفتح التطبيق مباشرة عند إعداد الملفات التالية على السيرفر.

## 📋 الملفات المطلوبة على السيرفر

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
# للـ Debug keystore
keytool -list -v -keystore android/app/debug.keystore -alias androiddebugkey -storepass android -keypass android

# للـ Release keystore (عند النشر)
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload
```

### 2. ملف iOS App Site Association
**المسار:** `https://hagz.app/.well-known/apple-app-site-association`

**المحتوى (بدون extension .json):**
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

**ملاحظات مهمة:**
- يجب أن يكون الملف بدون extension `.json`
- Content-Type يجب أن يكون `application/json`
- يجب أن يكون HTTPS (ليس HTTP)
- يجب أن يكون الملف متاحاً بدون redirect

### 3. صفحة Redirect (اختياري - للـ Fallback)
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

## 🔍 التحقق من الإعداد

### للـ Android:
1. افتح الرابط `https://hagz.app/.well-known/assetlinks.json` في المتصفح
2. يجب أن يظهر ملف JSON صحيح
3. تحقق من أن Content-Type هو `application/json`

### للـ iOS:
1. افتح الرابط `https://hagz.app/.well-known/apple-app-site-association` في المتصفح
2. يجب أن يظهر ملف JSON صحيح
3. تحقق من أن Content-Type هو `application/json`

## 📱 الاختبار

بعد إعداد الملفات على السيرفر:

1. **Android:**
   - افتح الرابط `https://hagz.app/doctor/{doctorId}` في Chrome
   - يجب أن يفتح التطبيق مباشرة

2. **iOS:**
   - افتح الرابط `https://hagz.app/doctor/{doctorId}` في Safari
   - يجب أن يفتح التطبيق مباشرة

## ⚠️ ملاحظات مهمة

1. بعد إضافة الملفات على السيرفر، قد يستغرق Android/iOS بعض الوقت للتحقق من الملفات (حتى 24 ساعة)
2. للتسريع، يمكن حذف بيانات التطبيق وإعادة تثبيته
3. يجب أن يكون السيرفر يدعم HTTPS
4. يجب أن يكون الملف متاحاً بدون redirect

## 🎯 النتيجة

بعد إعداد الملفات، الرابط `https://hagz.app/doctor/{doctorId}` سيعمل مثل Facebook:
- يظهر كرابط ويب عادي
- عند الضغط عليه، يفتح التطبيق مباشرة
- إذا لم يكن التطبيق مثبت، يفتح المتصفح

