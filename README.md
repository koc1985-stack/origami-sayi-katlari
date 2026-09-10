# Origami Sayı Katları

Bir sayı şeridini doğru sırayla "katlayarak" hedef sayıya ulaşman gereken sakin bir bulmaca oyunu. Şeritteki her hücre bir sayı, komşu hücreler arasındaki her katlama çizgisi bir `+` ya da `×` işlemi. Bir çizgiye dokunduğunda iki komşu hücre o işlemle tek hücrede birleşir; tüm şerit tek hücreye inince hedefe ulaştın mı ulaşamadın mı görürsün. `+` ve `×` değişmeli olduğu için hangi sırayla katladığın (parantezleme) sonucu değiştirir — bulmacanın özü de bu.

Bu proje **Windows üzerinde, kod düzeyinde tamamen yazıldı** ama iOS uygulamaları yalnızca **macOS + Xcode** üzerinde derlenip çalıştırılabildiği için, gerçek bir derleme/çalıştırma doğrulaması aşağıdaki adımlardan biriyle (tercihen Mac'siz TestFlight yöntemiyle) yapılmalı.

## Teknoloji

- SwiftUI, iOS 17+
- Tamamen yerel/offline — sunucu, hesap sistemi, reklam veya satın alma yok
- 10 elle seçilmiş level (`Sources/Data/Levels.swift`), `legacy-expo/scripts/generateLevels.ts` ve `verifyLevels.ts` ile üretilip doğrulanmıştı (bkz. "Eski Expo sürümü" bölümü)

## Kurulum (Mac üzerinde, tek seferlik)

1. [Xcode](https://apps.apple.com/app/xcode/id497799835) 15 veya üzerini App Store'dan kur.
2. [Homebrew](https://brew.sh) kuruluysa, [XcodeGen](https://github.com/yonaskolb/XcodeGen) kur:
   ```bash
   brew install xcodegen
   ```
3. Bu klasörde `.xcodeproj` dosyasını üret:
   ```bash
   cd GAME1
   xcodegen generate
   ```
4. `OrigamiSayiKatlari.xcodeproj` dosyasını Xcode ile aç.
5. Proje ayarlarında **Signing & Capabilities** sekmesinde kendi Apple Developer **Team**'ini seç. `project.yml` içindeki `PRODUCT_BUNDLE_IDENTIFIER` (`com.koc1985.origamisayikatlari`) placeholder — kendi bundle ID'ni kullanmak istersen `project.yml`'de değiştirip `xcodegen generate`'i tekrar çalıştır.
6. Bir Simulator seç (örn. iPhone 15) ve **Product ▸ Run** (⌘R).

## Mac'siz test (önerilen): GitHub Actions + TestFlight

`Impulse_Buy_Gatekeeper` projesinde kullandığın yöntemin aynısı: `.github/workflows/release-testflight.yml`, gerçek bir App Store Connect API anahtarıyla GitHub Actions'taki gerçek Xcode'u kullanıp uygulamayı doğru şekilde imzalayıp doğrudan TestFlight'a yüklüyor.

**Tek seferlik kurulum:**
1. [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → **My Apps** → **+** ile `com.koc1985.origamisayikatlari` bundle ID'siyle "Origami Sayı Katları" adında yeni bir uygulama kaydı aç (bundle ID'yi önceden **Certificates, Identifiers & Profiles** altında da oluşturman gerekebilir).
   - Aynı Apple Developer hesabını kullanıyorsan (Team ID `R6W7XU4TM7`), App Store Connect API anahtarını ve imzalama sertifikalarını Gatekeeper'da kullandıklarının **aynısını** tekrar kullanabilirsin — hesap seviyesinde, tek bir uygulamaya bağlı değiller.
2. Bu klasörü GitHub'da **ayrı, yeni bir repo** olarak aç ve push et (repo yoksa önce github.com'da boş bir repo oluştur).
3. GitHub reposu → Settings → Secrets and variables → Actions'a şu altı secret'i ekle (Gatekeeper reposundakiyle aynı değerler, sadece bu yeni repoya da eklenmesi gerekiyor):
   - `ASC_API_KEY_P8` (.p8 dosyasının tüm içeriği), `ASC_KEY_ID`, `ASC_ISSUER_ID`
   - `CERT_DEV_P12_BASE64`, `CERT_DIST_P12_BASE64`, `CERT_P12_PASSWORD`
4. GitHub'da **Actions** → "Release to TestFlight" → **Run workflow**. Bittiğinde Apple ~10-30 dakika işler, sonra iPhone'una **TestFlight** uygulamasını (App Store'dan ücretsiz) kurup içeride "Origami Sayı Katları"yı göreceksin.

Bundan sonra her `git push` otomatik olarak yeni bir TestFlight sürümü yükler.

## Mac'siz test (eski/yedek yöntem): GitHub Actions + Sideloadly

Mac'in yoksa `.github/workflows/build-ios.yml`, her `workflow_dispatch` tetiklemesinde imzasız bir `.ipa` üretir ve Actions çalışmasının **Artifacts** bölümüne yükler. Bu yöntem tek hedefli (uzantısız, App Group'suz) bu proje için Sideloadly ile sorunsuz çalışmalı — Gatekeeper'daki widget/Safari uzantısı gibi App Group gerektiren karmaşıklık burada yok.

1. GitHub'da **Actions** sekmesine gir, "Build iOS IPA" workflow'unu **Run workflow** ile tetikle.
2. Çalışma bitince **OrigamiSayiKatlari-ipa** artifact'ini indir, zip'i aç (`OrigamiSayiKatlari.ipa` çıkar).
3. Windows'a [Sideloadly](https://sideloadly.io) kur, iPhone'u USB ile bağla, `.ipa`'yı sürükle, Apple ID'ni gir.
4. iPhone'da **Ayarlar → Genel → VPN ve Cihaz Yönetimi** kısmından geliştirici profiline güvenmen gerekebilir.

Ücretsiz Apple ID ile imzalanan uygulamalar 7 günde bir yeniden imzalanmalı; ücretli Developer Program hesabıyla 1 yıla çıkar.

## Eski Expo sürümü

Oyun ilk olarak Expo/React Native ile yazılmıştı; o kod (`App.tsx`, `src/`, level üretici/doğrulayıcı script'ler dahil) referans için `legacy-expo/` klasöründe duruyor, artık derlenmiyor/kullanılmıyor. Yeni level eklemek istersen mantığı `legacy-expo/scripts/generateLevels.ts`'den bakıp `Sources/Data/Levels.swift`'e elle taşıman gerekir — v1'de otomatik üretici Swift'e taşınmadı.

## Proje yapısı

```
Sources/
  App/          — @main giriş noktası, Color(hex:) yardımcı
  Root/         — level seçim / oyun ekranı arası geçiş
  Models/       — GameOperator, GameCell, Crease, LevelDef, StripState
  Services/     — FoldEngine (katlama mantığı)
  Data/         — 10 level tanımı
  Features/
    LevelSelect/ — level seçim ızgarası
    Game/        — oyun ekranı, hücre/katlama düğmesi görünümleri
Resources/
  Assets.xcassets — AppIcon (eski Expo icon.png'den üretildi), AccentColor
legacy-expo/    — eski Expo/RN kaynak kodu, referans amaçlı
.github/workflows/
  build-ios.yml            — imzasız ipa (Sideloadly, eski/yedek yöntem)
  release-testflight.yml   — otomatik imzala + TestFlight'a yükle (önerilen yöntem)
```

Bir derleme hatası alırsan, hata mesajını buraya yapıştır — birlikte düzeltelim.
