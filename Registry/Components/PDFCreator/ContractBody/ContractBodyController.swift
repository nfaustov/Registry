//
//  ContractBodyController.swift
//  Registry
//
//  Created by Николай Фаустов on 07.04.2024.
//

import Foundation

struct ContractBodyController {
    private let patient: Patient
    private let services: [MedicalService]
    private let totalCost: Double

    init(patient: Patient, services: [MedicalService], totalCost: Double) {
        self.patient = patient
        self.services = services
        self.totalCost = totalCost
    }

    var firstPagePart: String {
        """
              ООО «УльтраМед», зарегистрированное инспекцией ФНС России по Советском району г. Липецка за основным государственным регистрационным номером 1104823005319 в Едином государственном реестре юридических лиц, далее именуемый Исполнитель, в лице директора Фаустова Н.И., действующего на основании  лицензии № ЛО-48-01-001195 от 12.08.2014 г. на осуществление медицинской деятельности (перечень работ (услуг): 2. При оказании первичной, в том числе доврачебной, врачебной и специализированной, медико-санитарной помощи организуются и выполняются следующие работы (услуги): 1) при оказании первичной доврачебной медико-санитарной помощи в амбулаторных условиях по: вакцинации (проведению профилактических прививок); медицинскому массажу; сестринскому делу; 2) при оказании первичной врачебной медико-санитарной помощи в амбулаторных условиях по: терапии; 4) при оказании специализированной медико-санитарной помощи в амбулаторных условиях по: акушерству и гинекологии (за исключением вспомогательных репродуктивных технологий); гастроэнтерологии; кардиологии; косметологии; неврологии; онкологии; сердечно-сосудистой хирургии; урологии; ультразвуковой диагностике; функциональной диагностике; эндокринологии; 7. При проведении медицинских осмотров, медицинских освидетельствований и медицинских экспертиз организуются и выполняются следующие работы (услуги): 1) при проведении медицинских осмотров по: медицинским осмотрам (предрейсовым, послерейсовым); 3) при проведении медицинских экспертиз по: экспертизе временной нетрудоспособности;), выданной Управлением здравоохранения Липецкой области, расположенного по адресу: г. Липецк, ул. Зегеля, д.6, телефон 23-80-10, и Устава, с одной стороны, \(patient.fullName) далее именуемый «Пациент», с другой стороны, вместе именуемые Стороны, заключили настоящий Договор о нижеследующем:
        1. ПРЕДМЕТ ДОГОВОРА
        1.1. Настоящий Договор определяет порядок и условия оказания платных медицинских услуг. Пациент поручает, а Исполнитель обязуется оказать Пациенту платную медицинскую услугу.
        1.2. Наименование услуг: \(enumeratedServices()).
        2. ПРАВА И ОБЯЗАННОСТИ СТОРОН
        2.1. Исполнитель обязуется:
        - оказать Пациенту квалифицированную, качественную медицинскую помощь;
        - выдать заключение с указанием результатов проведенных исследований.
        2.2. Исполнитель вправе:
        - отказать в проведении диагностических мероприятий в случае не выполнения Пациентом требований врача выполняющего исследование.
        - в случае возникновения неотложных состояний самостоятельно определять объем исследований, манипуляций, оперативных вмешательств, необходимых для установления диагноза и оказания медицинской помощи, в том числе не предусмотренных Договором.
        2.3. Пациент обязуется:
        - предоставить точную и достоверную информацию о состоянии своего здоровья. Информировать врача до оказания медицинской услуги о перенесенных заболеваниях, известных ему аллергических реакциях, противопоказаниях;
        - выполнять все медицинские рекомендации врача проводящего исследование;
        - своевременно проводить необходимые финансовые расчеты с лечебным учреждением.
        2.4. Пациент вправе:
        - получить полную и достоверную информацию о медицинской услуге;
        - ознакомиться с документами подтверждающими специальную правоспособность лечебного учреждения и его специалистов на оказание платной медицинской услуги;
        - отказаться от получения медицинской услуги и получить обратно сумму оплаты с возмещением Исполнителю затрат, связанных с подготовкой оказания услуги.
        3. ОТВЕТСТВЕННОСТИ СТОРОН
        3.1. В случае ненадлежащего оказания медицинской услуги, Пациент вправе потребовать безвозмездное устранение недостатков услуги, исполнения услуги другим специалистом или назначить новую дату оказания услуги.
        3.2. Исполнитель освобождается от ответственности за неисполнение или ненадлежащее исполнение своих обязательств по договору, если докажет, что это произошло вследствие непреодолимой силы, нарушения Пациентом своих обязанностей.
        3.3. Пациент обязан полностью возместить медицинскому учреждению понесенные убытки, если оно не смогло оказать услугу или было вынужденно прекратить оказание по вине Пациента.
        4. СТОИМОСТЬ И ПОРЯДОК ОПЛАТЫ
        4.1. Расчеты между сторонами осуществляются предварительно 100% оплатой.
        4.2. Оплата медицинской услуги производится безналичным перечислением на расчетный счет лечебного учреждения или внесения в кассу Исполнителя.
        4.3. При возникновении необходимости выполнения дополнительных услуг, не предусмотренных Договором, они выполняются с согласия Пациента с оплатой по утвержденному Прейскуранту.
        """
    }

    var aboveTablePart: String {
        """
        4.4. Цена медицинской услуги согласно Прейскуранту:
        """
    }

    var belowTablePart: String {
        """
        4.5. Общая стоимость медицинских услуг, предоставляемых Пациенту составляет \(String(format: "%.2f", totalCost)) рублей (\(totalCostInWords())).
        5. ПРОЧИЕ УСЛОВИЯ
        5.1. Настоящий Договор вступает в силу с момента его подписания Сторонами и действует до полного и надлежащего исполнения сторонами всех его условий.
        5.2. Условия настоящего Договора могут быть изменены по письменному соглашению Сторон.
        5.3. Споры и разногласия решаются путем переговоров, привлечения независимой экспертизы и в судебном порядке.
        6. АДРЕСА И РЕКВИЗИТЫ СТОРОН
        """
    }

    var companyDetails: String {
        """
        Медицинская клиника "АртМедикс"
        ООО "УльтраМед"
        398000, г. Липецк, пр. Победы, 6, оф. 2
        Телефон: +7 (4742) 25-04-04
        ИНН/КПП 4826072119/482401001
        ОГРН 1104823005319
        e-mail: clinic@artmedics.ru


        """
    }

    var passportDetails: String {
        if patient.passport.isValid {
        return """
        Дата рождения: \(DateFormat.date.string(from: patient.passport.birthday))
        Серия и номер паспорта: \(patient.passport.seriesNumber)
        Выдан: \(patient.passport.authority) \(DateFormat.date.string(from: patient.passport.issueDate))
        """
        } else {
            return """
        
        
        
        """
        }
    }

    var patientDetails: String {
        """
        \(patient.fullName)
        \(passportDetails)




        """
    }

    var freeMedicineInforming: String {
        """
              Пациенту предоставлена в доступной форме информация о возможности получения соответствующих видов и объемов медицинской помощи без взимания платы в рамках программы государственных гарантий бесплатного оказания гражданам медицинской помощи и территориальной программы государственных гарантий бесплатного оказания гражданам медицинской помощи. Отказ Пациента от заключения договора не может быть причиной уменьшения видов и объемов медицинской помощи, предоставляемых такому Пациенту без взимания платы в рамках государственной программы и территориальной программы.
        """
    }

    var followingRecommendationsInforming: String {
        """
              До заключения договора Пациент уведомлен о том, что несоблюдение указаний (рекомендаций) Исполнителя (медицинского работника, предоставляющего платную медицинскую услугу), в том числе назначенного режима лечения, могут снизить качество предоставляемой платной медицинской услуги, повлечь за собой невозможность ее завершения в срок или отрицательно сказаться на состоянии здоровья Пациента.
        """
    }
}

private extension ContractBodyController {
    var currenсyTitle: String {
        var remainder = Int(totalCost) % 1_000_000

        if remainder > 100_000 {
            remainder = remainder % 100_000
        }
        if remainder > 10_000 {
            remainder = remainder % 10_000
        }
        if remainder > 1000 {
            remainder = remainder % 1000
        }
        if remainder > 100 {
            remainder = remainder % 100
        }
        if remainder > 19 {
            remainder = remainder % 10
        }

        switch remainder {
        case 1: return "рубль"
        case 2, 3, 4: return "рубля"
        default: return "рублей"
        }
    }

    func enumeratedServices() -> String {
        var enumeratedServices = services.map { $0.title }.reduce("") { $0 + ", " + $1 }
        if !enumeratedServices.isEmpty {
            enumeratedServices.removeFirst()
        }

        return enumeratedServices
    }

    func totalCostInWords() -> String {
        let numberValue = NSNumber(value: totalCost)
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.numberStyle = .spellOut
        let priceString = formatter.string(from: numberValue) ?? "\(totalCost)"

        return "\(priceString) \(currenсyTitle) 00 копеек"
    }
}
