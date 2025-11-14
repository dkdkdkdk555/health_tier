# Naver SDK 관련 ProGuard 설정
-keep class com.navercorp.** { *; }
-dontwarn com.navercorp.**

-keep class com.nhn.** { *; }
-dontwarn com.nhn.**

# Kakao SDK 관련 ProGuard 설정
-keep class com.kakao.** { *; }
-dontwarn com.kakao.**

# OkHttp3에서 동적 로딩되는 Conscrypt 관련 클래스 유지
-keep class org.conscrypt.** { *; }
-dontwarn org.conscrypt.**

# OpenJSSE 관련 클래스 유지
-keep class org.openjsse.** { *; }
-dontwarn org.openjsse.**