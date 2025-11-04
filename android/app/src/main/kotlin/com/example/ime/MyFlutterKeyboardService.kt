package com.example.ime

import android.inputmethodservice.InputMethodService
import android.view.View
import android.view.inputmethod.InputConnection
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class MyFlutterKeyboardService : InputMethodService() {

    // المعرف الفريد للمحرك المخزن في الذاكرة المؤقتة
    companion object {
        const val FLUTTER_ENGINE_ID = "my_keyboard_engine"
    }

    private var flutterEngine: FlutterEngine? = null
    private var flutterView: FlutterView? = null
    private lateinit var methodChannel: MethodChannel

    override fun onCreate() {
        super.onCreate()

        // ## الخطوة 1: الحصول على المحرك أو إنشاؤه ##
        // نحاول أولاً الحصول على المحرك من الذاكرة المؤقتة
        flutterEngine = FlutterEngineCache.getInstance().get(FLUTTER_ENGINE_ID)

        // إذا لم يكن المحرك موجوداً (عند تشغيل لوحة المفاتيح لأول مرة)
        if (flutterEngine == null) {
            // نقوم بإنشاء محرك جديد
            flutterEngine = FlutterEngine(this)
            flutterEngine!!.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )
            // ونقوم بتخزينه في الذاكرة المؤقتة لاستخدامه لاحقاً
            FlutterEngineCache.getInstance().put(FLUTTER_ENGINE_ID, flutterEngine!!)
        }

        // إعداد قناة الاتصال (MethodChannel) على المحرك الموجود
        methodChannel = MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "com.example.flutter_keyboard/keyboard")
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "handleInput" -> {
                    val text = call.argument<String>("text")
                    if (text != null) {
                        handleInput(text)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Text argument is missing.", null)
                    }
                }
                "handleDelete" -> {
                    handleDelete()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreateInputView(): View {
        // ## الخطوة 2: إنشاء الواجهة وربطها بالمحرك ##
        // في كل مرة تظهر لوحة المفاتيح، ننشئ واجهة FlutterView جديدة
        // ونربطها بالمحرك المخزن لدينا
        
        // كود حماية للتأكد من أن المحرك ليس فارغاً
        if (flutterEngine == null) return View(this)

        flutterView = FlutterView(this).apply {
            attachToFlutterEngine(this@MyFlutterKeyboardService.flutterEngine!!)
        }
        return flutterView!!
    }

    override fun onFinishInputView(finishingInput: Boolean) {
        super.onFinishInputView(finishingInput)
        // ## الخطوة 3: فصل الواجهة عند الإخفاء ##
        // عند إخفاء لوحة المفاتيح، نفصل الواجهة عن المحرك
        // هذا يسمح للمحرك بالبقاء حياً في الخلفية وجاهزاً للاستخدام التالي
        flutterView?.detachFromFlutterEngine()
        flutterView = null
    }

    // دالة لإرسال النص إلى حقل الإدخال
    private fun handleInput(text: String) {
        val ic: InputConnection? = currentInputConnection
        ic?.commitText(text, 1)
    }

    // دالة للتعامل مع أمر الحذف
    private fun handleDelete() {
        val ic: InputConnection? = currentInputConnection
        ic?.deleteSurroundingText(1, 0)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        // ## الخطوة 4: عدم تدمير المحرك ##
        // هذا هو التعديل الأهم. لا يجب تدمير المحرك هنا.
        // المحرك يجب أن يبقى في الذاكرة المؤقتة (Cache) طوال الوقت.
        // الواجهة (flutterView) يتم التعامل معها في onFinishInputView.
    }
}
