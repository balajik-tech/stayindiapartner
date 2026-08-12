-dontwarn com.google.firebase.iid.**
-keep class com.google.firebase.iid.** { *; }

# ML Kit Text Recognition
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# General ML Kit rules
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**
