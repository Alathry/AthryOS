#!/usr/bin/env bash

# 1. التأكد من توفر cava لتجنب انهيار السكربت أو Waybar
if ! command -v cava &> /dev/null; then
    echo "Cava not found"
    exit 1
fi

# 2. إنشاء ملف مؤقت آمن لتجنب تداخل العمليات (Race Conditions)
config_file=$(mktemp /tmp/waybar_cava_XXXXXX.conf)

# 3. حذف الملف المؤقت تلقائياً عند إغلاق السكربت أو إعادة تشغيل Waybar
trap 'rm -f "$config_file"' EXIT INT TERM

# كتابة الإعدادات
cat <<EOF > "$config_file"
[general]
bars = 14
framerate = 60
autosens = 1
sensitivity = 100
lower_cutoff_freq = 50
higher_cutoff_freq = 10000

[smoothing]
monstercat = 1
noise_reduction = 0.77

[output]
method = raw
data_format = ascii
ascii_max_range = 7
EOF

# 4. استخدام stdbuf لتعطيل التخزين المؤقت وضمان وصول البيانات لـ awk فوراً
stdbuf -oL cava -p "$config_file" | awk -F ';' '
BEGIN {
    # تجهيز المصفوفة مرة واحدة فقط
    split(" ;▂;▃;▄;▅;▆;▇;█", icons, ";")
}
{
    str = ""
    # NF-1 لأن cava يضيف فاصلة منقوطة فارغة في نهاية كل سطر
    for (i = 1; i < NF; i++) {
        val = $i
        
        # استخدام المعامل الثلاثي (Ternary) لسرعة التنفيذ بدلاً من كثرة الشروط
        val = (val < 0) ? 0 : ((val > 7) ? 7 : val)
        
        str = str icons[val + 1]
    }
    print str
    
    # 5. الحل السحري: استخدام fflush() بدلاً من system("")
    # يقوم بتحديث المخرجات فوراً لـ Waybar بدون استهلاك أي طاقة إضافية من المعالج
    fflush()
}'
