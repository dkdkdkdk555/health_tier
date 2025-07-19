# Naver SDK 관련 ProGuard 설정
-keep class com.naver.** { *; }
-dontwarn com.naver.**

# OkHttp3에서 동적 로딩되는 Conscrypt 관련 클래스 유지
-keep class org.conscrypt.** { *; }
-dontwarn org.conscrypt.**

# OpenJSSE 관련 클래스 유지
-keep class org.openjsse.** { *; }
-dontwarn org.openjsse.**