# Keep Bouncy Castle classes
-keep class org.bouncycastle.** { *; }

# Keep Conscrypt classes
-keep class org.conscrypt.** { *; }

# Keep Java WebSocket classes
-keep class org.java_websocket.** { *; }

# Keep OpenJSSE classes
-keep class org.openjsse.** { *; }

# Suppress warnings for missing classes
-dontwarn org.bouncycastle.jsse.BCSSLParameters
-dontwarn org.bouncycastle.jsse.BCSSLSocket
-dontwarn org.bouncycastle.jsse.provider.BouncyCastleJsseProvider
-dontwarn org.conscrypt.Conscrypt$Version
-dontwarn org.conscrypt.Conscrypt
-dontwarn org.conscrypt.ConscryptHostnameVerifier
-dontwarn org.java_websocket.client.WebSocketClient
-dontwarn org.java_websocket.drafts.Draft
-dontwarn org.java_websocket.drafts.Draft_6455
-dontwarn org.openjsse.javax.net.ssl.SSLParameters
-dontwarn org.openjsse.javax.net.ssl.SSLSocket
-dontwarn org.openjsse.net.ssl.OpenJSSE