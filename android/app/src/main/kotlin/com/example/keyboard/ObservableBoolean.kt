// package com.example.ime.views

// class ObservableBoolean(initialValue: Boolean = false) {
//     private val listeners = mutableListOf<(Boolean) -> Unit>()
//     var value: Boolean = initialValue
//         set(newValue) {
//             if (field != newValue) {
//                 field = newValue
//                 listeners.forEach { it.invoke(newValue) }
//             }
//         }
//     fun addOnChangeListener(listener: (Boolean) -> Unit) {
//         listeners.add(listener)
//     }
//     fun removeOnChangeListener(listener: (Boolean) -> Unit) {
//         listeners.remove(listener)
//     }
//     fun clearListeners() {
//         listeners.clear()
//     }
// }
