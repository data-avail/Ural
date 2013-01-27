/// <reference path="../Src/knockout.validation.js" />

/************************************************
* This is an example localization page. All of these
* messages are the default messages for ko.validation
* 
* Currently ko.validation only does a single parameter replacement
* on your message (indicated by the {0}).
*
* The parameter that you provide in your validation extender
* is what is passed to your message to do the {0} replacement.
*
* eg: myProperty.extend({ minLength: 5 });
* ... will provide a message of "Please enter at least 5 characters"
* when validated
*
* This message replacement obviously only works with primitives
* such as numbers and strings. We do not stringify complex objects 
* or anything like that currently.
*/
(function (factory) {

    // Module systems magic dance.

    if (typeof require === "function" && typeof exports === "object" && typeof module === "object") {
        // CommonJS or Node: hard-coded dependency on "knockout"
        factory(require("knockout", "knockout.validation"), exports);
    } else if (typeof define === "function" && define["amd"]) {
        // AMD anonymous module with hard-coded dependency on "knockout"
        define(["knockout", "exports"], factory);
    } else {
        // <script> tag: use the global `ko` object, attaching a `mapping` property
        factory(ko, ko.mapping = {});
    }
}(function (ko, exports) {

    ko.validation.localize({
        required: 'Поле должно быть заполнено.',
        min: 'Значение поле должно быть большим или равным {0}.',
        max: 'Значение поле должно быть меньшим или равным {0}.',
        minLength: 'Строка должна содержать как минимум {0} символов.',
        maxLength: 'Количество символов в строке не должно превышать {0} знаков.',
        pattern: 'Проверьте значение.',
        step: 'Значение должно быть увеличено на {0}.',
        email: '{0} не правильный email.',
        date: 'Введите дату в правильном формате.',
        dateISO: 'Введите дату в правильном формате.',
        number: 'Поле должно содержать цифровое значение.',
        digit: 'Поле должно содержать цифровое значение.',
        phoneUS: 'Номер телефона не в праильном формате.',
        equal: 'Значения должны быть равными.',
        notEqual: 'Выберите другое значение.',
        unique: 'Данное значение должно быть уникальным.'
    });
}));