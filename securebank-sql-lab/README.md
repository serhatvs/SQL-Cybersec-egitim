# SecureBank SQL Lab

SecureBank SQL Lab, "SQL 101 ve Veritabani Guvenligi Atolyesi" icin hazirlanmis basit bir Docker tabanli egitim ortamidir. Katilimcilar tarayicidan Adminer paneline baglanarak PostgreSQL uzerindeki sahte SecureBank v1.0 veritabani ile SQL sorgulari calistirabilir.

Bu proje bir web uygulamasi degildir. Amac, SQL temellerini ve veritabani guvenligi konularini guvenli bir demo verisiyle calismaktir.

## Gereksinimler

- Docker
- Docker Compose

## Hizli Baslangic

```bash
docker compose up -d
```

Calisan konteynerleri kontrol etmek icin:

```bash
docker ps
```

## Adminer'i Acma

Ayni bilgisayardan baglanmak icin:

```text
http://localhost:8080
```

Ayni Wi-Fi veya yerel agdaki katilimcilar icin:

```text
http://HOST_IP:8080
```

`HOST_IP`, Docker'i calistiran egitmen bilgisayarinin yerel ag IP adresidir.

## Opsiyonel: ngrok ile public link açma

Okul Wi-Fi ağında cihazlar birbirine erişemiyorsa Adminer panelini geçici public linke çevirmek için kullanılabilir. Bu yöntem mevcut Docker Compose yapısını değiştirmez; sadece bu bilgisayardaki `http://localhost:8080` Adminer paneli için geçici bir HTTP tüneli açar.

**Güvenlik uyarısı:** Bu yöntem Adminer login ekranını internete açar. Sadece etkinlik sırasında kullanın, etkinlik bitince ngrok’u kapatın. PostgreSQL portu `5432` için ngrok tüneli açmayın.

Arch/CachyOS icin ngrok kurulumu:

```bash
sudo pacman -S ngrok
```

Eger pacman paketi yoksa:

```bash
yay -S ngrok
```

Alternatif olarak resmi ngrok indirme sayfasindan kurulum yapabilirsiniz:

```text
https://ngrok.com/download
```

ngrok hesabinizdan aldiginiz auth token'i kendi bilgisayarinizda bir kez tanimlayin:

```bash
ngrok config add-authtoken YOUR_TOKEN
```

Gercek token'i repository'ye commit etmeyin. `.env` dosyasi kullaniliyorsa ignore altinda kalmalidir; bu repo `.env`, `.ngrok2/`, `ngrok.yml` ve `*.log` dosyalarini ignore eder.

Kullanim:

```bash
docker compose up -d
./start-ngrok.sh
```

Terminalde `Forwarding` satirinda buna benzer bir URL gorursunuz:

```text
https://example.ngrok-free.app
```

Ogrenciler bu URL'yi tarayicida acar.

## Workshop safety checklist

- Yerel ag disina aciyorsaniz guclu DB sifreleri kullanin.
- ngrok linkini sadece katilimcilarla paylasin.
- Atolye bitince ngrok'u durdurun.
- PostgreSQL portu `5432` icin public tunnel acmayin.
- Mümkün olduğunda yerel ağ erişimini tercih edin.
- Public erisimden sonra lab sifrelerini yenileyin veya sifirlayin.

## Adminer Giris Bilgileri

- System: `PostgreSQL`
- Server: `db`
- Username: `admin`
- Password: `securebank123`
- Database: `securebank`

## DB01 - SQL Basics

DB01, SQL'e yeni baslayan ogrenciler icin hazirlanmis cok sade bir pratik veritabanidir. Bu veritabani SQL Injection, Red Team veya Blue Team calismasi icin degildir. Amac yalnizca `SELECT`, `WHERE`, `ORDER BY`, `LIMIT`, temel karsilastirma operatorleri ve basit filtreleme pratigi yapmaktir.

Veritabani bilgileri:

- DB name: `db01_sql_basics`
- Username: `db01_user`
- Password: `db01pass123`
- Yetki: `customers` tablosunda sadece `SELECT`

Adminer giris bilgileri:

- System: `PostgreSQL`
- Server: `db`
- Username: `db01_user`
- Password: `db01pass123`
- Database: `db01_sql_basics`

Tablo:

```text
customers
```

Kolonlar:

- `id`
- `full_name`
- `city`
- `age`
- `balance`
- `account_type`
- `is_active`
- `created_at`

DB01 ornek alistirmalar ve beklenen sorgular:

1. Tum musterileri listele

```sql
SELECT * FROM customers;
```

2. Sadece ad soyad ve sehir bilgisini goster

```sql
SELECT full_name, city
FROM customers;
```

3. Kayseri'deki musterileri bul

```sql
SELECT *
FROM customers
WHERE city = 'Kayseri';
```

4. Bakiyesi 50000'den buyuk musterileri bul

```sql
SELECT *
FROM customers
WHERE balance > 50000;
```

5. Aktif musterileri bul

```sql
SELECT *
FROM customers
WHERE is_active = true;
```

6. Musterileri bakiyeye gore buyukten kucuge sirala

```sql
SELECT *
FROM customers
ORDER BY balance DESC;
```

7. En zengin 5 musteriyi goster

```sql
SELECT *
FROM customers
ORDER BY balance DESC
LIMIT 5;
```

8. Yasi 30'dan buyuk musterileri bul

```sql
SELECT *
FROM customers
WHERE age > 30;
```

9. Student hesaplari bul

```sql
SELECT *
FROM customers
WHERE account_type = 'student';
```

10. Ankara'da olup bakiyesi 10000'den buyuk musterileri bul

```sql
SELECT *
FROM customers
WHERE city = 'Ankara'
  AND balance > 10000;
```

## DB02 - İlişkisel Mantık ve JOIN

DB02, iliskisel veritabani mantigini ve baslangic seviye JOIN sorgularini ogretmek icin hazirlanmistir. Bu veritabani SQL Injection, Red Team veya Blue Team calismasi icin degildir. Amac Primary Key, Foreign Key, one-to-many iliski, `INNER JOIN` ve `LEFT JOIN` kavramlarini sade banka hesaplari verisiyle calismaktir.

Veritabani bilgileri:

- DB name: `db02_relations_joins`
- Username: `db02_user`
- Password: `db02pass123`
- Yetki: DB02 tablolarinda sadece `SELECT`

Adminer giris bilgileri:

- System: `PostgreSQL`
- Server: `db`
- Username: `db02_user`
- Password: `db02pass123`
- Database: `db02_relations_joins`

Tablolar ve iliski:

- `customers`: Musteri kayitlari
- `accounts`: Musterilere ait banka hesaplari
- Iliski: `accounts.customer_id`, `customers.id` alanina baglidir.
- Bir müşteri birden fazla hesaba sahip olabilir.

DB02 ornek alistirmalar ve beklenen sorgular:

1. Tum musterileri listele

```sql
SELECT *
FROM customers;
```

2. Tum hesaplari listele

```sql
SELECT *
FROM accounts;
```

3. INNER JOIN ile musteri adlarini ve IBAN bilgilerini goster

```sql
SELECT c.full_name, a.iban
FROM customers c
JOIN accounts a ON c.id = a.customer_id;
```

4. Musteri adi, sehir, hesap tipi ve bakiye bilgilerini goster

```sql
SELECT c.full_name, c.city, a.account_type, a.balance
FROM customers c
JOIN accounts a ON c.id = a.customer_id;
```

5. Kayseri'deki musterilere ait tum hesaplari bul

```sql
SELECT c.full_name, c.city, a.iban, a.balance
FROM customers c
JOIN accounts a ON c.id = a.customer_id
WHERE c.city = 'Kayseri';
```

6. Bakiyesi 50000'den buyuk hesabi olan musterileri bul

```sql
SELECT c.full_name, a.iban, a.balance
FROM customers c
JOIN accounts a ON c.id = a.customer_id
WHERE a.balance > 50000;
```

7. Hesabi olmasa bile tum musterileri LEFT JOIN ile goster

```sql
SELECT c.full_name, a.iban, a.balance
FROM customers c
LEFT JOIN accounts a ON c.id = a.customer_id;
```

8. Musteri basina hesap sayisini bul

```sql
SELECT c.full_name, COUNT(a.id) AS account_count
FROM customers c
LEFT JOIN accounts a ON c.id = a.customer_id
GROUP BY c.id, c.full_name
ORDER BY c.full_name;
```

9. Musteri basina toplam bakiyeyi hesapla

```sql
SELECT c.full_name, COALESCE(SUM(a.balance), 0) AS total_balance
FROM customers c
LEFT JOIN accounts a ON c.id = a.customer_id
GROUP BY c.id, c.full_name
ORDER BY total_balance DESC;
```

10. Hic hesabi olmayan musterileri bul

```sql
SELECT c.full_name, c.city
FROM customers c
LEFT JOIN accounts a ON c.id = a.customer_id
WHERE a.id IS NULL;
```

## DB03 - Bankacılık Sorguları ve Analiz

DB03, gercekci bankacilik ve fintech SQL analiz sorgulari icin hazirlanmis sahte bir egitim veritabanidir. Bu veritabani SQL Injection, Red Team veya Blue Team calismasi icin degildir. Amac cok tablolu `SELECT` sorgulari, JOIN, `ORDER BY`, `LIMIT`, `GROUP BY`, `COUNT`, `SUM`, `AVG`, tarih/durum/tip filtreleme ve temel islem analizi pratigi yapmaktir.

Bu veritabanı bankacılık sistemlerinde sık görülen müşteri, hesap, kart, şube ve işlem verileri üzerinde SQL analizi yapmak için hazırlanmıştır.

Veritabani bilgileri:

- DB name: `db03_banking_queries`
- Username: `db03_user`
- Password: `db03pass123`
- Yetki: DB03 tablolarinda sadece `SELECT`

Adminer giris bilgileri:

- System: `PostgreSQL`
- Server: `db`
- Username: `db03_user`
- Password: `db03pass123`
- Database: `db03_banking_queries`

Tablolar ve iliskiler:

- `customers`: Musteri bilgileri ve segmentleri
- `accounts`: Musterilere ait hesaplar
- `transactions`: Hesaplar arasindaki islem hareketleri
- `cards`: Musterilere ait kartlar ve limitler
- `branches`: Sube bilgileri
- `account_branches`: Hesap ve sube iliskisi
- Bir musteri birden fazla hesaba ve karta sahip olabilir.
- Bir hesap birden fazla islem gonderebilir veya alabilir.
- Hesaplar `account_branches` tablosu uzerinden subelere baglanir.

DB03 ornek alistirmalar ve beklenen sorgular:

1. Tum musterileri listele

```sql
SELECT *
FROM customers;
```

2. Tum aktif hesaplari listele

```sql
SELECT *
FROM accounts
WHERE status = 'active';
```

3. Musterileri hesaplari ve bakiyeleriyle goster

```sql
SELECT c.full_name, a.iban, a.account_type, a.balance
FROM customers c
JOIN accounts a ON c.id = a.customer_id
ORDER BY a.balance DESC;
```

4. Son 10 islemi goster

```sql
SELECT t.id, t.transaction_type, t.amount, t.status, t.created_at
FROM transactions t
ORDER BY t.created_at DESC
LIMIT 10;
```

5. 50000 uzerindeki islemleri bul

```sql
SELECT t.id, t.amount, t.transaction_type, t.status, t.created_at
FROM transactions t
WHERE t.amount > 50000
ORDER BY t.amount DESC;
```

6. Musteri basina hesap sayisini bul

```sql
SELECT c.full_name, COUNT(a.id) AS account_count
FROM customers c
LEFT JOIN accounts a ON c.id = a.customer_id
GROUP BY c.id, c.full_name
ORDER BY account_count DESC;
```

7. Musteri basina toplam bakiyeyi hesapla

```sql
SELECT c.full_name, SUM(a.balance) AS total_balance
FROM customers c
JOIN accounts a ON c.id = a.customer_id
GROUP BY c.id, c.full_name
ORDER BY total_balance DESC;
```

8. Hesap basina toplam giden islem tutarini hesapla

```sql
SELECT a.iban, SUM(t.amount) AS total_outgoing_amount
FROM accounts a
JOIN transactions t ON a.id = t.from_account_id
GROUP BY a.id, a.iban
ORDER BY total_outgoing_amount DESC;
```

9. Basarisiz islemleri bul

```sql
SELECT t.id, t.amount, t.transaction_type, t.description, t.created_at
FROM transactions t
WHERE t.status = 'failed'
ORDER BY t.created_at DESC;
```

10. Toplam bakiyesi 100000'den buyuk premium musterileri bul

```sql
SELECT c.full_name, c.customer_segment, SUM(a.balance) AS total_balance
FROM customers c
JOIN accounts a ON c.id = a.customer_id
WHERE c.customer_segment = 'premium'
GROUP BY c.id, c.full_name, c.customer_segment
HAVING SUM(a.balance) > 100000
ORDER BY total_balance DESC;
```

11. Sube bazli toplam hesap bakiyesini goster

```sql
SELECT b.branch_name, b.city, SUM(a.balance) AS total_branch_balance
FROM branches b
JOIN account_branches ab ON b.id = ab.branch_id
JOIN accounts a ON ab.account_id = a.id
GROUP BY b.id, b.branch_name, b.city
ORDER BY total_branch_balance DESC;
```

12. Musterileri kartlari ve aylik limitleriyle goster

```sql
SELECT c.full_name, ca.card_type, ca.masked_card_no, ca.monthly_limit
FROM customers c
JOIN cards ca ON c.id = ca.customer_id
ORDER BY ca.monthly_limit DESC;
```

## DB04 - Broken Access Control / Yetki Kontrolü Lab

DB04, Broken Access Control ve IDOR tarzı yetki kontrolü hatalarını guvenli ve egitim odakli bicimde gostermek icin hazirlanmistir. Bu veritabani SQL Injection degildir; exploit payload icermez. Amac, SQL sorgusu dogru olsa bile uygulamanin kullanici-yetki kontrolunu yapmasi gerektigini gostermektir.

Bu veritabanı SQL Injection değil; yetki kontrolü hatalarını göstermek için hazırlanmıştır. Doğru SQL sorgusu yazmak yeterli değildir; kullanıcının o veriye erişim yetkisi olup olmadığı da kontrol edilmelidir.

Bir kullanıcı sadece kendi hesaplarını veya kendisine izin verilen hesapları görebilmelidir.

Veritabani bilgileri:

- DB name: `db04_access_control_lab`
- Username: `db04_user`
- Password: `db04pass123`
- Yetki: DB04 tablolarinda sadece `SELECT`

Adminer giris bilgileri:

- System: `PostgreSQL`
- Server: `db`
- Username: `db04_user`
- Password: `db04pass123`
- Database: `db04_access_control_lab`

Tablolar ve iliskiler:

- `app_users`: Uygulama kullanicilari; musteri, destek personeli ve auditor rolleri
- `accounts`: Hesaplar; `owner_user_id`, `app_users.id` alanina baglidir
- `account_access`: Hangi kullanicinin hangi hesaba erisebilecegini gosterir
- `account_view_events`: Hesap goruntuleme olaylarini tutar
- `support_tickets`: Destek taleplerini ve ilgili hesaplari tutar
- `security_notes`: Yetki kontrolu notlari
- `account_access`, bu lab icin izin tablosudur.
- `account_view_events`, izinsiz erisimleri denetlemek icin kullanilir.
- Supheli erisimler, goruntuleme olaylari ile izin kayitlari karsilastirilarak bulunur.

DB04 ornek alistirmalar ve beklenen sorgular:

1. Tum kullanicilari listele

```sql
SELECT *
FROM app_users;
```

2. Tum hesaplari sahip adlariyla listele

```sql
SELECT a.id, u.full_name AS owner_name, a.iban, a.account_type, a.balance
FROM accounts a
JOIN app_users u ON a.owner_user_id = u.id
ORDER BY a.id;
```

3. `account_access` tablosundaki tum izin kayitlarini listele

```sql
SELECT aa.id, u.username, a.iban, aa.access_level, aa.granted_reason
FROM account_access aa
JOIN app_users u ON aa.user_id = u.id
JOIN accounts a ON aa.account_id = a.id
ORDER BY aa.id;
```

4. Ali Yilmaz'in erisebildigi hesaplari goster

```sql
SELECT u.full_name, a.iban, aa.access_level, aa.granted_reason
FROM app_users u
JOIN account_access aa ON u.id = aa.user_id
JOIN accounts a ON aa.account_id = a.id
WHERE u.full_name = 'Ali Yilmaz';
```

5. Tum hesap goruntuleme olaylarini goster

```sql
SELECT *
FROM account_view_events
ORDER BY created_at;
```

6. Goruntuleme olaylarini kullanici adlari ve hesap IBAN bilgileriyle goster

```sql
SELECT ave.id, u.username, a.iban, ave.source, ave.ip_address, ave.created_at
FROM account_view_events ave
JOIN app_users u ON ave.viewer_user_id = u.id
JOIN accounts a ON ave.viewed_account_id = a.id
ORDER BY ave.created_at;
```

7. Kendi hesabini goruntuleyen kullanicilari bul

```sql
SELECT ave.id, u.full_name, a.iban, ave.created_at
FROM account_view_events ave
JOIN app_users u ON ave.viewer_user_id = u.id
JOIN accounts a ON ave.viewed_account_id = a.id
WHERE a.owner_user_id = ave.viewer_user_id;
```

8. Destek personeli tarafindan yapilan hesap goruntulemelerini bul

```sql
SELECT ave.id, u.username, a.iban, ave.source, ave.created_at
FROM account_view_events ave
JOIN app_users u ON ave.viewer_user_id = u.id
JOIN accounts a ON ave.viewed_account_id = a.id
WHERE u.role = 'support_staff'
ORDER BY ave.created_at;
```

9. Eslesen izin kaydi olmayan supheli hesap goruntulemelerini bul

```sql
SELECT
  ave.id,
  viewer.username AS viewer_username,
  a.iban AS viewed_iban,
  ave.source,
  ave.ip_address,
  ave.created_at
FROM account_view_events ave
JOIN app_users viewer ON ave.viewer_user_id = viewer.id
JOIN accounts a ON ave.viewed_account_id = a.id
LEFT JOIN account_access aa
  ON aa.user_id = ave.viewer_user_id
 AND aa.account_id = ave.viewed_account_id
WHERE aa.id IS NULL;
```

Ayni kontrolun `NOT EXISTS` versiyonu:

```sql
SELECT
  ave.id,
  viewer.username AS viewer_username,
  a.iban AS viewed_iban,
  ave.source,
  ave.ip_address,
  ave.created_at
FROM account_view_events ave
JOIN app_users viewer ON ave.viewer_user_id = viewer.id
JOIN accounts a ON ave.viewed_account_id = a.id
WHERE NOT EXISTS (
  SELECT 1
  FROM account_access aa
  WHERE aa.user_id = ave.viewer_user_id
    AND aa.account_id = ave.viewed_account_id
);
```

10. Kullanici basina supheli goruntuleme sayisini hesapla

```sql
SELECT viewer.username, COUNT(*) AS suspicious_view_count
FROM account_view_events ave
JOIN app_users viewer ON ave.viewer_user_id = viewer.id
LEFT JOIN account_access aa
  ON aa.user_id = ave.viewer_user_id
 AND aa.account_id = ave.viewed_account_id
WHERE aa.id IS NULL
GROUP BY viewer.id, viewer.username
ORDER BY suspicious_view_count DESC;
```

11. Destek taleplerini talep eden kisi ve ilgili hesap IBAN bilgisiyle goster

```sql
SELECT st.id, u.full_name AS requester_name, a.iban, st.subject, st.status, st.created_at
FROM support_tickets st
JOIN app_users u ON st.requester_user_id = u.id
LEFT JOIN accounts a ON st.related_account_id = a.id
ORDER BY st.created_at;
```

12. Neden sadece `account_id` ile filtrelemek tehlikelidir?

Yalnizca hesap ID'sine bakmak, kullanicinin o hesaba erisim yetkisini kontrol etmez:

```sql
SELECT *
FROM accounts a
WHERE a.id = 5;
```

Daha guvenli mantik, kullanicinin izin kaydini da kontrol eder:

```sql
SELECT a.*
FROM accounts a
JOIN account_access aa ON aa.account_id = a.id
JOIN app_users u ON u.id = aa.user_id
WHERE a.id = 5
  AND u.username = 'ali.yilmaz';
```

## DB05 - SQL Injection Lab

DB05, SQL Injection kavramini yalnizca yerel ve kontrollu bir egitim ortaminda, savunma odakli olarak anlatmak icin hazirlanmistir. Bu bolum gercek sistemlere yonelik test, saldiri veya otomatik arac kullanimi icin degildir.

Bu bölüm sadece yerel eğitim/lab ortamı içindir. Gerçek sistemlerde izinsiz test yapmak yasaktır.

SQL Injection, kullanıcı girdisinin doğrudan SQL sorgusuna eklenmesi sonucu sorgu mantığının değiştirilebilmesidir.

Savunma için temel yöntem prepared statements / parameterized queries kullanmaktır.

Bu bolumdeki sorgular tespit ve analiz ornekleridir; gercek sistemlere yonelik saldiri talimati degildir.

Veritabani bilgileri:

- DB name: `db05_sql_injection_lab`
- Username: `db05_user`
- Password: `db05pass123`
- Yetki: DB05 tablolarinda sadece `SELECT`

Adminer giris bilgileri:

- System: `PostgreSQL`
- Server: `db`
- Username: `db05_user`
- Password: `db05pass123`
- Database: `db05_sql_injection_lab`

Tablolar ve iliskiler:

- `app_users`: Uygulama kullanicilari; musteri, personel ve admin rolleri
- `customer_profiles`: Musteri profil bilgileri; `user_id`, `app_users.id` alanina baglidir
- `vulnerable_query_examples`: Guvensiz pseudo-query ornekleri ve guvenli alternatifler
- `input_attempt_logs`: Uygulama girdisi loglari; normal, supheli ve yuksek riskli isaretleri analiz etmek icin
- `safe_query_checklist`: SQL Injection onleme kontrol listesi
- `security_flags`: Egitim amacli lab flag kaydi

DB05 ornek alistirmalar ve beklenen sorgular:

1. Tum uygulama kullanicilarini listele

```sql
SELECT *
FROM app_users;
```

2. Sadece staff ve admin kullanicilarini listele

```sql
SELECT *
FROM app_users u
WHERE u.role IN ('staff', 'admin');
```

3. Musteri profillerini kullanici adlariyla goster

```sql
SELECT u.username, u.full_name, cp.city, cp.risk_level, cp.kyc_status
FROM app_users u
JOIN customer_profiles cp ON u.id = cp.user_id
ORDER BY u.username;
```

4. Tum guvensiz sorgu orneklerini listele

```sql
SELECT *
FROM vulnerable_query_examples vqe
ORDER BY vqe.id;
```

5. Guvensiz kaliplari ve guvenli kaliplari yan yana goster

```sql
SELECT vqe.example_name, vqe.unsafe_pattern, vqe.safe_pattern
FROM vulnerable_query_examples vqe
ORDER BY vqe.feature_area;
```

6. Tum input attempt loglarini listele

```sql
SELECT *
FROM input_attempt_logs ial
ORDER BY ial.created_at;
```

7. Supheli veya yuksek riskli input girislerini bul

```sql
SELECT
  ial.source_ip,
  ial.feature_area,
  ial.input_value,
  ial.normalized_risk,
  ial.detected_reason,
  ial.created_at
FROM input_attempt_logs ial
WHERE ial.normalized_risk IN ('suspicious', 'high')
ORDER BY ial.created_at DESC;
```

8. Risk seviyesine gore input sayisini hesapla

```sql
SELECT ial.normalized_risk, COUNT(*) AS attempt_count
FROM input_attempt_logs ial
GROUP BY ial.normalized_risk
ORDER BY ial.normalized_risk;
```

9. Feature area bazinda supheli deneme sayisini hesapla

```sql
SELECT
  ial.feature_area,
  ial.normalized_risk,
  COUNT(*) AS attempt_count
FROM input_attempt_logs ial
WHERE ial.normalized_risk IN ('suspicious', 'high')
GROUP BY ial.feature_area, ial.normalized_risk
ORDER BY ial.feature_area, ial.normalized_risk;
```

Genel gruplama ornegi:

```sql
SELECT
  feature_area,
  normalized_risk,
  COUNT(*) AS attempt_count
FROM input_attempt_logs
GROUP BY feature_area, normalized_risk
ORDER BY feature_area, normalized_risk;
```

10. Quote karakteri veya comment marker iceren loglari `LIKE` ile bul

```sql
SELECT
  ial.source_ip,
  ial.feature_area,
  ial.input_value,
  ial.detected_reason
FROM input_attempt_logs ial
WHERE ial.input_value LIKE '%''%'
   OR ial.input_value LIKE '%--%'
ORDER BY ial.id;
```

11. Guvenli sorgu kontrol listesini kategoriye gore listele

```sql
SELECT sqc.category, sqc.checklist_item, sqc.explanation
FROM safe_query_checklist sqc
ORDER BY sqc.category, sqc.id;
```

12. Parameterized query kullanmanin neden onemli oldugunu acikladiktan sonra egitim flag kaydini goster

Prepared statements / parameterized queries, kullanici girdisini SQL sorgu yapisindan ayirir. Bu sayede girdi veri olarak islenir ve sorgu mantigini degistirmemelidir.

```sql
SELECT flag_name, flag_value, note
FROM security_flags
WHERE flag_name = 'training_flag_05';
```

## DB06 - Audit Log ve Adli Bilişim Lab

DB06, SQL'in siber guvenlikte log analizi, olay inceleme ve adli bilisim dusuncesi icin nasil kullanildigini gostermek amaciyla hazirlanmistir. Bu veritabani saldiri yapmak icin degil; savunma, korelasyon ve zaman cizelgesi analizi icindir.

Bu veritabanı saldırı yapmak için değil; log analizi, olay inceleme ve şüpheli davranış tespiti için hazırlanmıştır.

Amaç SQL kullanarak kim, ne zaman, nereden, hangi aksiyonu yaptı sorularına cevap bulmaktır.

Veritabani bilgileri:

- DB name: `db06_audit_forensics_lab`
- Username: `db06_user`
- Password: `db06pass123`
- Yetki: DB06 tablolarinda sadece `SELECT`

Adminer giris bilgileri:

- System: `PostgreSQL`
- Server: `db`
- Username: `db06_user`
- Password: `db06pass123`
- Database: `db06_audit_forensics_lab`

Tablolar ve iliskiler:

- `app_users`: Musteri, destek personeli, analist ve admin kullanicilari
- `devices`: Kullanicilara ait cihazlar; `devices.user_id`, `app_users.id` alanina baglidir
- `ip_reputation`: IP adresi itibari ve risk bilgisi
- `auth_logs`: Login, logout, MFA ve parola sifirlama olaylari
- `query_activity_logs`: Veritabani sorgu ve aktivite olaylari
- `security_events`: Guvenlik olaylari ve onem dereceleri
- `incident_notes`: Analist notlari ve inceleme ipuclari
- `auth_logs` ve `query_activity_logs`, kullanici ve IP adresi uzerinden birlikte analiz edilebilir.

DB06 ornek alistirmalar ve beklenen sorgular:

1. Tum kullanicilari listele

```sql
SELECT *
FROM app_users;
```

2. Tum cihazlari sahip kullanici adlariyla listele

```sql
SELECT u.username, d.device_name, d.device_type, d.os_name, d.trusted
FROM devices d
JOIN app_users u ON d.user_id = u.id
ORDER BY u.username, d.device_name;
```

3. Tum IP reputation kayitlarini listele

```sql
SELECT *
FROM ip_reputation ipr
ORDER BY ipr.reputation, ipr.ip_address;
```

4. Basarisiz login denemelerini goster

```sql
SELECT u.username, al.ip_address, al.failure_reason, al.created_at
FROM auth_logs al
JOIN app_users u ON al.user_id = u.id
WHERE al.event_type = 'login'
  AND al.success = false
ORDER BY al.created_at;
```

5. Kullanici basina basarisiz login sayisini hesapla

```sql
SELECT
  u.username,
  COUNT(*) AS failed_login_count
FROM auth_logs al
JOIN app_users u ON al.user_id = u.id
WHERE al.event_type = 'login'
  AND al.success = false
GROUP BY u.username
ORDER BY failed_login_count DESC;
```

6. 3'ten fazla basarisiz login denemesi olan kullanicilari bul

```sql
SELECT
  u.username,
  COUNT(*) AS failed_login_count
FROM auth_logs al
JOIN app_users u ON al.user_id = u.id
WHERE al.event_type = 'login'
  AND al.success = false
GROUP BY u.username
HAVING COUNT(*) > 3
ORDER BY failed_login_count DESC;
```

7. Supheli veya malicious IP'lerden gelen login denemelerini goster

```sql
SELECT
  u.username,
  al.event_type,
  al.success,
  al.ip_address,
  ipr.reputation,
  al.created_at
FROM auth_logs al
JOIN app_users u ON al.user_id = u.id
LEFT JOIN ip_reputation ipr ON al.ip_address = ipr.ip_address
WHERE ipr.reputation IN ('suspicious', 'malicious')
ORDER BY al.created_at;
```

8. Auth loglarini IP reputation bilgisiyle birlestir

```sql
SELECT u.username, al.event_type, al.success, al.ip_address, ipr.reputation, ipr.note
FROM auth_logs al
JOIN app_users u ON al.user_id = u.id
LEFT JOIN ip_reputation ipr ON al.ip_address = ipr.ip_address
ORDER BY al.created_at;
```

9. Malicious IP'den basarili login olaylarini bul

```sql
SELECT u.username, al.ip_address, ipr.reputation, al.created_at
FROM auth_logs al
JOIN app_users u ON al.user_id = u.id
JOIN ip_reputation ipr ON al.ip_address = ipr.ip_address
WHERE al.event_type = 'login'
  AND al.success = true
  AND ipr.reputation = 'malicious'
ORDER BY al.created_at;
```

10. High-risk query activity loglarini goster

```sql
SELECT u.username, qal.ip_address, qal.database_name, qal.action_type, qal.object_name, qal.row_count, qal.created_at
FROM query_activity_logs qal
JOIN app_users u ON qal.user_id = u.id
WHERE qal.risk_level = 'high'
ORDER BY qal.created_at;
```

11. `export_report` aksiyonu yapan kullanicilari bul

```sql
SELECT u.username, qal.ip_address, qal.database_name, qal.object_name, qal.row_count, qal.risk_level, qal.created_at
FROM query_activity_logs qal
JOIN app_users u ON qal.user_id = u.id
WHERE qal.action_type = 'export_report'
ORDER BY qal.created_at;
```

12. Supheli IP icin zaman cizelgesi olustur

```sql
SELECT
  'AUTH' AS log_type,
  u.username,
  al.ip_address,
  al.event_type AS action,
  al.created_at
FROM auth_logs al
JOIN app_users u ON al.user_id = u.id
WHERE al.ip_address = '185.220.101.45'

UNION ALL

SELECT
  'QUERY' AS log_type,
  u.username,
  qal.ip_address,
  qal.action_type AS action,
  qal.created_at
FROM query_activity_logs qal
JOIN app_users u ON qal.user_id = u.id
WHERE qal.ip_address = '185.220.101.45'

ORDER BY created_at;
```

13. Guvenlik olaylarini severity degerine gore say

```sql
SELECT se.severity, COUNT(*) AS event_count
FROM security_events se
GROUP BY se.severity
ORDER BY event_count DESC;
```

14. Kullanicilar, auth loglari ve query activity loglarini birlestirerek supheli davranisi incele

```sql
SELECT
  u.username,
  u.role,
  al.ip_address,
  ipr.reputation,
  al.event_type,
  al.success,
  qal.action_type,
  qal.risk_level,
  qal.created_at AS query_time
FROM app_users u
JOIN auth_logs al ON u.id = al.user_id
JOIN query_activity_logs qal
  ON qal.user_id = u.id
 AND qal.ip_address = al.ip_address
LEFT JOIN ip_reputation ipr ON al.ip_address = ipr.ip_address
WHERE al.success = true
  AND (ipr.reputation IN ('suspicious', 'malicious') OR qal.risk_level = 'high')
ORDER BY qal.created_at;
```

## DB07 - AI ile SQL Üretme ve Doğrulama Lab

DB07, AI tarafindan uretilen SQL sorgularinin dikkatli sekilde dogrulanmasi gerektigini ogretmek icin hazirlanmistir. Bu lab SQL Injection, Red Team veya Blue Team calismasi degildir; AI SQL validasyonu, hata ayiklama ve guvenli insan-onayli is akisi icindir.

Bu veritabanı AI tarafından üretilen SQL sorgularının körü körüne kullanılmaması gerektiğini göstermek için hazırlanmıştır.

Amaç AI çıktısını tablo/kolon, mantık, filtre, performans ve güvenlik açısından kontrol etmektir.

Veritabani bilgileri:

- DB name: `db07_ai_sql_risk_lab`
- Username: `db07_user`
- Password: `db07pass123`
- Yetki: DB07 tablolarinda sadece `SELECT`

Adminer giris bilgileri:

- System: `PostgreSQL`
- Server: `db`
- Username: `db07_user`
- Password: `db07pass123`
- Database: `db07_ai_sql_risk_lab`

Tablolar ve iliskiler:

- `employees`: Calisan bilgileri; `department_id`, `departments.id` alanina baglidir
- `departments`: Departmanlar ve yonetici calisan referansi
- `projects`: Projeler; `department_id`, `departments.id` alanina baglidir
- `project_assignments`: Calisan-proje atamalari; `employee_id` ve `project_id` ile baglanir
- `expenses`: Harcama kayitlari; calisan ve proje bilgisine baglanir
- `ai_prompt_examples`: AI araclarina verilebilecek dogal dil prompt ornekleri
- `ai_generated_queries`: Hatalı AI SQL ciktisi, sorun tipi, risk seviyesi ve duzeltilmis SQL
- `validation_checklist`: Insan tarafindan yapilmasi gereken kontrol adimlari

Kisa AI SQL dogrulama kontrol listesi:

- Tablo var mi?
- Kolonlar var mi?
- JOIN yolu dogru mu?
- WHERE filtresi dogru mu?
- Sorgu gereksiz fazla veri cekiyor mu?
- Hassas alanlari aciga cikarabilir mi?
- Sorgu yeterince verimli mi?

DB07 ornek alistirmalar ve beklenen sorgular:

1. Tum calisanlari listele

```sql
SELECT *
FROM employees;
```

2. Departmanlari ve calisanlarini listele

```sql
SELECT d.department_name, e.full_name, e.role, e.city
FROM departments d
JOIN employees e ON e.department_id = d.id
ORDER BY d.department_name, e.full_name;
```

3. Aktif projeleri departman adlariyla goster

```sql
SELECT p.project_name, d.department_name, p.budget, p.status
FROM projects p
JOIN departments d ON p.department_id = d.id
WHERE p.status = 'active'
ORDER BY p.project_name;
```

4. Proje atamalarini calisan ve proje adlariyla goster

```sql
SELECT e.full_name, p.project_name, pa.assignment_role, pa.allocated_hours
FROM project_assignments pa
JOIN employees e ON pa.employee_id = e.id
JOIN projects p ON pa.project_id = p.id
ORDER BY p.project_name, e.full_name;
```

5. Proje basina toplam harcama tutarini goster

```sql
SELECT p.project_name, COALESCE(SUM(ex.amount), 0) AS total_expense
FROM projects p
LEFT JOIN expenses ex ON ex.project_id = p.id
GROUP BY p.id, p.project_name
ORDER BY total_expense DESC;
```

6. Onaylanmamis harcamalari bul

```sql
SELECT ex.id, e.full_name, p.project_name, ex.expense_type, ex.amount, ex.created_at
FROM expenses ex
JOIN employees e ON ex.employee_id = e.id
LEFT JOIN projects p ON ex.project_id = p.id
WHERE ex.approved = false
ORDER BY ex.created_at;
```

7. Birden fazla projede calisan calisanlari bul

```sql
SELECT e.full_name, COUNT(pa.project_id) AS project_count
FROM employees e
JOIN project_assignments pa ON e.id = pa.employee_id
GROUP BY e.id, e.full_name
HAVING COUNT(pa.project_id) > 1
ORDER BY project_count DESC;
```

8. AI prompt orneklerini listele

```sql
SELECT *
FROM ai_prompt_examples ape
ORDER BY ape.id;
```

9. Yuksek riskli AI-generated query kayitlarini listele

```sql
SELECT
  agq.id,
  ape.intent_summary,
  agq.issue_type,
  agq.risk_level,
  agq.explanation
FROM ai_generated_queries agq
JOIN ai_prompt_examples ape ON agq.prompt_id = ape.id
WHERE agq.risk_level = 'high'
ORDER BY agq.issue_type;
```

10. AI query sorunlarini issue_type degerine gore say

```sql
SELECT
  issue_type,
  COUNT(*) AS issue_count
FROM ai_generated_queries
GROUP BY issue_type
ORDER BY issue_count DESC;
```

11. AI'in hallucinated column kullandigi ornekleri goster

```sql
SELECT agq.id, ape.prompt_text, agq.generated_sql, agq.explanation, agq.corrected_sql
FROM ai_generated_queries agq
JOIN ai_prompt_examples ape ON agq.prompt_id = ape.id
WHERE agq.issue_type = 'hallucinated_column'
ORDER BY agq.id;
```

12. AI'in hassas veriyi fazla cektigi ornekleri goster

```sql
SELECT
  agq.id,
  ape.prompt_text,
  agq.generated_sql,
  agq.explanation,
  agq.corrected_sql
FROM ai_generated_queries agq
JOIN ai_prompt_examples ape ON agq.prompt_id = ape.id
WHERE agq.issue_type = 'over_fetching'
   OR agq.issue_type = 'sensitive_data_exposure'
ORDER BY agq.id;
```

13. Bir prompt icin generated_sql ve corrected_sql alanlarini karsilastir

```sql
SELECT
  ape.prompt_text,
  agq.issue_type,
  agq.generated_sql,
  agq.corrected_sql,
  agq.explanation
FROM ai_generated_queries agq
JOIN ai_prompt_examples ape ON agq.prompt_id = ape.id
WHERE agq.prompt_id = 6
ORDER BY agq.id;
```

14. Validation checklist maddelerini kategoriye gore listele

```sql
SELECT vc.category, vc.checklist_item, vc.explanation
FROM validation_checklist vc
ORDER BY vc.category, vc.id;
```

## DB08 - Red vs Blue Final Challenge

DB08, "SQL 101 ve Veritabani Guvenligi Atolyesi" final challenge veritabanidir. Bankacilik senaryosu, SQL Injection kavrami, Broken Access Control, audit/log analizi, least privilege ve Red Team / Blue Team hedeflerini tek bir sade lab ortaminda birlestirir.

Bu bölüm sadece yerel lab ortamı içindir. Gerçek sistemlere saldırı veya izinsiz test yapmak yasaktır.

Bu DB gerçek bir web exploit ortamı değildir; SQL panel üzerinden güvenlik mantığını analiz etmek için sadeleştirilmiş bir final labıdır.

Red Team hedefi: Sistemdeki zayıf sorgu/yetki mantığını analiz ederek challenge flag’e ulaşmaya çalışır.

Blue Team hedefi: Zafiyetin nedenini analiz eder, suspicious logları bulur, prepared statement ve least privilege ile savunma önerir.

Veritabani bilgileri:

- DB name: `db08_red_vs_blue_final`
- Red user: `db08_red_user`
- Red password: `db08redpass123`
- Blue user: `db08_blue_user`
- Blue password: `db08bluepass123`

Red Team Adminer giris bilgileri:

- System: `PostgreSQL`
- Server: `db`
- Username: `db08_red_user`
- Password: `db08redpass123`
- Database: `db08_red_vs_blue_final`

Blue Team Adminer giris bilgileri:

- System: `PostgreSQL`
- Server: `db`
- Username: `db08_blue_user`
- Password: `db08bluepass123`
- Database: `db08_red_vs_blue_final`

Yetki modeli:

- `db08_red_user`: Challenge-facing tablolarda `SELECT` yetkisine sahiptir. `security_flags` tablosuna dogrudan erisemez; sade final lab akisi icin `exposed_challenge_results` view'i uzerinden flag sonucunu gorebilir.
- `db08_blue_user`: Tum DB08 tablolarinda `SELECT`, `defense_findings` tablosunda `INSERT`, `challenge_config` tablosunda `UPDATE` yetkisine sahiptir.

Tablolar ve iliskiler:

- `app_users`: Musteri, support staff, auditor ve admin kullanicilari
- `accounts`: Hesaplar; `owner_user_id`, `app_users.id` alanina baglidir
- `transactions`: Hesaplar arasi islemler
- `account_access`: Kullanici-hesap yetki kayitlari
- `support_tickets`: Musteri destek talepleri
- `vulnerable_query_notes`: Guvensiz pseudo-code notlari ve savunma aciklamalari
- `input_attempt_logs`: Supheli input denemelerini analiz etmek icin loglar
- `audit_logs`: Genel uygulama/veritabani aktivite loglari
- `admin_notes`: Korumali ic notlar; restricted data olarak dusunulmelidir
- `security_flags`: Final challenge flag tablosu; Red Team icin dogrudan acik degildir
- `exposed_challenge_results`: Sadelestirilmis challenge-facing flag view'i
- `challenge_config`: Blue Team savunma durumunu isaretleyebilir
- `defense_findings`: Blue Team bulgu ve onerilerini kaydedebilir

DB08 challenge gorevleri ve beklenen sorgular:

1. Red Team: Gorulebilen uygulama kullanicilarini listele

```sql
SELECT u.id, u.username, u.full_name, u.role, u.status
FROM app_users u
ORDER BY u.id;
```

2. Red Team: Admin veya staff hesaplarini belirle

```sql
SELECT u.username, u.full_name, u.role
FROM app_users u
WHERE u.role IN ('admin', 'support_staff', 'auditor')
ORDER BY u.role, u.username;
```

3. Red Team: Vulnerable query notlarini incele

```sql
SELECT vqn.feature_area, vqn.unsafe_pattern, vqn.why_vulnerable, vqn.safe_pattern
FROM vulnerable_query_notes vqn
ORDER BY vqn.id;
```

4. Red Team: Supheli input denemelerini bul

```sql
SELECT
  source_ip,
  feature_area,
  input_value,
  normalized_risk,
  detected_reason,
  created_at
FROM input_attempt_logs
WHERE normalized_risk IN ('suspicious', 'high')
ORDER BY created_at DESC;
```

5. Red Team: Supheli IP ile audit loglarini korele et

```sql
SELECT al.source_ip, al.action_type, al.object_name, al.row_count, al.risk_level, al.created_at
FROM audit_logs al
WHERE al.source_ip = '185.220.101.45'
ORDER BY al.created_at;
```

6. Red Team: Restricted gibi gorunen tablolari ve challenge-facing view'i belirle

```sql
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('admin_notes', 'security_flags', 'exposed_challenge_results')
ORDER BY table_name;
```

7. Red Team: Challenge-facing flag view'ini kontrol et

```sql
SELECT flag_name, flag_value
FROM exposed_challenge_results;
```

8. Red Team: Hangi mantik hatasi exposure'a yol acmis olabilir?

```sql
SELECT vqn.feature_area, vqn.why_vulnerable, vqn.defense_note
FROM vulnerable_query_notes vqn
WHERE vqn.feature_area IN ('account_lookup', 'admin_note_filter');
```

9. Blue Team: High-risk input denemelerini listele

```sql
SELECT ial.source_ip, ial.username_attempt, ial.feature_area, ial.input_value, ial.detected_reason, ial.created_at
FROM input_attempt_logs ial
WHERE ial.normalized_risk = 'high'
ORDER BY ial.created_at DESC;
```

10. Blue Team: Feature area bazinda supheli deneme sayisini hesapla

```sql
SELECT ial.feature_area, ial.normalized_risk, COUNT(*) AS attempt_count
FROM input_attempt_logs ial
WHERE ial.normalized_risk IN ('suspicious', 'high')
GROUP BY ial.feature_area, ial.normalized_risk
ORDER BY attempt_count DESC;
```

11. Blue Team: `185.220.101.45` IP'si icin zaman cizelgesi olustur

```sql
SELECT
  'INPUT' AS log_type,
  source_ip,
  feature_area AS action,
  input_value AS details,
  created_at
FROM input_attempt_logs
WHERE source_ip = '185.220.101.45'

UNION ALL

SELECT
  'AUDIT' AS log_type,
  source_ip,
  action_type AS action,
  object_name AS details,
  created_at
FROM audit_logs
WHERE source_ip = '185.220.101.45'

ORDER BY created_at;
```

12. Blue Team: Audit log ve account_access karsilastirmasiyla yetkisiz hesap goruntuleme desenlerini bul

```sql
SELECT
  al.id,
  u.username,
  al.source_ip,
  al.object_name AS viewed_iban,
  al.created_at
FROM audit_logs al
JOIN app_users u ON al.actor_user_id = u.id
JOIN accounts a ON al.object_name = a.iban
LEFT JOIN account_access aa
  ON aa.user_id = al.actor_user_id
 AND aa.account_id = a.id
WHERE al.action_type = 'view_account'
  AND aa.id IS NULL
ORDER BY al.created_at;
```

13. Blue Team: Vulnerable query notlarini savunma onerileriyle incele

```sql
SELECT vqn.feature_area, vqn.why_vulnerable, vqn.safe_pattern, vqn.defense_note
FROM vulnerable_query_notes vqn
ORDER BY vqn.feature_area;
```

14. Blue Team: Defense finding kaydi ekle

```sql
INSERT INTO defense_findings
  (finding_title, finding_body, severity, suggested_fix)
VALUES
  (
    'Parametresiz sorgu riski',
    'Kullanici girdisi SQL sorgusuna dogrudan eklenirse sorgu mantigi degisebilir.',
    'high',
    'Prepared statement kullan, sort/filter alanlari icin allow-list uygula, DB yetkilerini kisitla.'
  );
```

15. Blue Team: `challenge_config` defense status degerini guncelle

```sql
UPDATE challenge_config
SET config_value = 'patched_proposed'
WHERE config_key = 'defense_status';
```

16. Blue Team: Kisa mitigasyon plani icin kontrol maddelerini listele

```sql
SELECT
  'prepared statements' AS control_area,
  'Kullanici girdisini SQL metnine ekleme; parametre olarak bagla.' AS recommendation
UNION ALL
SELECT 'allow-listing', 'Sort/filter alanlari icin izinli deger listesi kullan.'
UNION ALL
SELECT 'least privilege', 'Red ve uygulama rollerine sadece gerekli tablo/view yetkilerini ver.'
UNION ALL
SELECT 'generic error messages', 'Detayli SQL hata mesajlarini kullaniciya gosterme.'
UNION ALL
SELECT 'audit monitoring', 'Input attempt ve audit loglarini risk seviyesine gore izle.';
```

## Ornek SQL Sorgulari

Tum kullanicilari listele:

```sql
SELECT * FROM users;
```

Tum hesaplari listele:

```sql
SELECT * FROM accounts;
```

Bakiyesi 50000 uzerinde olan hesaplari bul:

```sql
SELECT id, iban, account_type, balance, currency, status
FROM accounts
WHERE balance > 50000
ORDER BY balance DESC;
```

Son 10 islemi goster:

```sql
SELECT *
FROM transactions
ORDER BY created_at DESC
LIMIT 10;
```

Kullanicilari hesaplariyla birlikte goster:

```sql
SELECT
    u.username,
    u.full_name,
    a.iban,
    a.account_type,
    a.balance,
    a.currency,
    a.status
FROM users u
JOIN accounts a ON a.user_id = u.id
ORDER BY u.id, a.id;
```

Gonderen ve alici hesaplarla birlikte transferleri goster:

```sql
SELECT
    t.id,
    sender.iban AS sender_iban,
    receiver.iban AS receiver_iban,
    t.amount,
    t.status,
    t.description,
    t.created_at
FROM transactions t
JOIN accounts sender ON sender.id = t.from_account_id
JOIN accounts receiver ON receiver.id = t.to_account_id
ORDER BY t.created_at DESC;
```

## Atolye Notlari

- Bu ortam tamamen sahte verilerle hazirlanmis bir egitim laboratuvaridir.
- Gercek musteri, banka, kart, hesap veya kimlik bilgisi kullanmayin.
- Gercek sistemlere saldiri yapmayin.
- Sorgulari yalnizca bu yerel lab ortaminda calistirin.

## Sorun Giderme

Konteynerleri kontrol et:

```bash
docker ps
```

Loglari incele:

```bash
docker compose logs
```

Sadece konteynerleri durdur:

```bash
docker compose down
```

Tum veriyi silerek sifirla:

```bash
docker compose down -v
docker compose up -d
```

Hazir reset betigini kullanmak icin:

```bash
chmod +x reset-lab.sh
./reset-lab.sh
```

## Ag Notu

Katilimcilarin `http://HOST_IP:8080` adresiyle baglanabilmesi icin egitmen bilgisayariyla ayni Wi-Fi veya yerel agda olmalari gerekir. Guvenlik duvari kullaniliyorsa 8080 portuna yerel agdan erisim izni verilmelidir.
