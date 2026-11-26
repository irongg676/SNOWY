# SNOWY ❄️ — Modular Universal Foundation v2.5

هذه الحزمة تجعل واجهة SNOWY وأدوات الجلسة مستقلة عن لعبة معينة، وتضيف طبقة **GameAdapter** لتوصيل تكاملات خاصة بالألعاب عند توفر واجهات موثقة ومصرح بها. ليست كل ميكانيكيات Roblox موحدة؛ لذلك لا يمكن ضمان Auto Carry أو Auto Exit أو ESP أو Server Finder في كل لعبة بمجرد تشغيل ملف واحد.

## هيكل المستودع

```text
SNOWY/
├── SNOWY.lua              # شغّل هذا الملف فقط
├── SNOWY_OLD.lua          # النسخة الأصلية الاحتياطية
├── README.md
├── assets/                # موارد اختيارية
└── src/
    ├── Main.lua           # الواجهة وربط الوحدات
    ├── Settings.lua       # الإعدادات
    ├── Theme.lua          # ألوان SNOWY
    ├── UI.lua             # عناصر الواجهة والسحب
    ├── Notifications.lua  # الإشعارات
    └── GameAdapter.lua    # عقد التكامل الخاص بكل لعبة
```

## الوظائف المتاحة في هذه الحزمة
- واجهة داكنة بنفسجية/زرقاء، قابلة للسحب والتصغير والإخفاء.
- معلومات الجلسة الحالية: عدد اللاعبين وPlace ID وJob ID وعمر الجلسة.
- تحديث المعلومات ونسخ Job ID وPlace ID ومعلومات السيرفر إذا كانت الحافظة مدعومة.
- إشعارات وإعادة موضع الواجهة وإزالة الواجهة.
- عرض واضح لحالة التوافق بدلاً من أزرار وهمية.

## التوافق مع الألعاب
لا توجد طريقة موحدة لمعرفة عنصر قابل للحمل أو لحظة إيداعه أو بيانات السيرفرات الخاصة بكل لعبة. `GameAdapter.lua` هو نقطة التوصيل: يجب إضافة تكامل منفصل لكل لعبة باستخدام واجهات موثقة ومصرح بها. حالياً لا يوجد Adapter مفعّل، لذا Auto Carry وAuto Exit التلقائي وPlayer ESP وServer Value Finder ليست وظائف عاملة في هذه النسخة.

## الرفع والتشغيل على Android
1. فك ضغط ZIP.
2. ارفع **محتويات** هذا المجلد إلى جذر `irongg676/SNOWY` في فرع `main`، مع الحفاظ على المسارات والأسماء.
3. اجعل المستودع Public إذا كنت تعتمد على raw.githubusercontent.com، ولا تضع أسراراً فيه.
4. شغّل `SNOWY.lua` فقط من بيئة Luau التي تدعم `game:HttpGet` و`loadstring`.

رابط المشغّل: `https://raw.githubusercontent.com/irongg676/SNOWY/main/SNOWY.lua`

## الاختبار
لم يتم اختبار هذه الحزمة داخل Delta أو على جهاز Android. دعم `loadstring` وطلبات HTTP والحافظة يختلف حسب بيئة التنفيذ.
\n\n## v2.5 UI update\n\nAdded visible action buttons to Carry, Exit, and ESP pages. These buttons perform compatibility checks and report unsupported integrations; they do not pretend that game-specific automation is active.\n