-keep class androidx.work.impl.background.gcm.** { *; }
-keep class androidx.work.impl.background.systemjob.** { *; }
-keepclassmembers class * {
    @androidx.work.WorkerParameters$NetworkType *;
}
