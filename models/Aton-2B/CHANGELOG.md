# سجل التغييرات

All notable changes to the **Akhet-Aton-2B** model distribution are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.1.1] - 2026-11-05

### أضيف
- إضافة سكربت التقييم والاختبار الآلي [`eval_aton_2b.py`](eval_aton_2b.py) لقياس ومحاكاة أداء النموذج عبر حالات الاستخدام الست الأساسية وفحص الالتزام بالحدود التشغيلية.

### تم التعديل
- تحديث وتصحيح بطاقات التوثيق (`README.md`, `MODEL_CARD.md`, `MODEL_CARD_AR.md`) لإبراز دور النموذج كوكيل محلي ثنائي اللغة مخصص للأتمتة وهيكلة المهام (حالات الاستخدام الست الأساسية ومحددات التشغيل).
- تنظيف المستندات وإزالة أي روابط مطلقة أو مسارات محلية، ومواءمة المستندات للنشر على المستودع الرسمي `alwkala/Aton`.
- إضافة محرك الواجهة الرسومية الأصلية `Alwkala AI Studio` ومزامنة أدوات التشغيل التكيفية.

## [0.1.0] - 2026-11-04

### أضيف
- توحيد وتسمية ملفات التكميم الثنائي GGUF لتوثيق هوية Alwkala Digital Labs:
  - `Aton-2B-Q4_K_M.gguf` (1.31 GB) — النموذج اللغوي الأساسي، متضمناً البيانات الوصفية الداخلية لهوية المطور (Alwkala Digital Labs).
  - `Aton-2B-F16-mmproj.gguf` (668 MB) — محول الرؤية البصري CLIP، متضمناً البيانات الوصفية الداخلية لهوية المطور (Alwkala Digital Labs).
- توثيق وضبط البيانات الوصفية الشاملة في `metadata.json` و `export_metadata.json` تحت هوية Alwkala Digital Labs.
- إضافة هوية المطور والمنظومة إلى ملفات التكوين القياسية لـ Transformers و Hugging Face Hub:
  - `config.json`
  - `preprocessor_config.json`
  - `processor_config.json`
  - `video_preprocessor_config.json`
  - `adapter_config.json`
  - `tokenizer_config.json`
  - `tokenizer.json`
  - `chat_template.jinja`
- إنشاء بطاقات التوثيق الرسمية بالإنجليزية `README.md` وبالعربية `MODEL_CARD_AR.md`.
- بناء سكربت التشغيل التكيفي متعدد الوسائط `run-Aton-Adaptive.ps1` مع لوحة TUI حية وأنماط تشغيل متقدمة (Apex-1, Duo-2, Swarm-4).
- ضبط تتبع الملفات الثنائية عبر `.gitattributes`.
