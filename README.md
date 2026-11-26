# SNOWY ❄️ — Steal a Brainrot Edition v2.6

هذه النسخة مخصصة لتجربة Roblox الأصلية **Steal a Brainrot**.

## التعرّف على اللعبة
- Universe ID: `7709344486`
- Root Place ID: `109983668079237`
- يعتمد `src/GameAdapter.lua` على Universe ID حتى يتعرّف على الأماكن الفرعية التابعة للتجربة أيضاً.
- يستخدم Root Place ID كخيار احتياطي إذا لم توفر بيئة التشغيل Universe ID.

## هيكل المستودع

```text
SNOWY/
├── SNOWY.lua
├── SNOWY_OLD.lua
├── README.md
├── assets/
└── src/
    ├── Main.lua
    ├── Settings.lua
    ├── Theme.lua
    ├── UI.lua
    ├── Notifications.lua
    └── GameAdapter.lua
```

## ما يعمل في v2.6
- واجهة SNOWY الداكنة والسحب والتصغير والإخفاء.
- معلومات الجلسة الحالية، تحديثها ونسخها.
- الإشعارات وإعداداتها وإعادة موضع النافذة.
- التعرّف على Steal a Brainrot باستخدام Universe ID عبر الأماكن التابعة للتجربة.

## ما لم يُنفّذ بعد
حالة التعرّف على اللعبة لا تعني أن الأتمتة أصبحت جاهزة. Auto Carry وAuto Exit بعد تأكيد الإيداع وPlayer ESP وServer Value Finder ما زالت غير منفذة في هذا الإصدار، وتظهر حالتها بوضوح بدلاً من تفعيل أزرار وهمية.

## التثبيت والتشغيل
1. فك ضغط الحزمة.
2. ارفع محتويات مجلد `SNOWY_COMPLETE` إلى جذر المستودع `irongg676/SNOWY` في فرع `main` مع الحفاظ على الأسماء والمسارات.
3. شغّل `SNOWY.lua` فقط من بيئة Luau التي تدعم `game:HttpGet` و`loadstring`.

رابط المشغّل:
`https://raw.githubusercontent.com/irongg676/SNOWY/main/SNOWY.lua`

## الاختبار
تم التحقق من بنية ZIP ووجود الملفات المطلوبة. لم يتم اختبار التشغيل داخل Delta أو على جهاز Android.
