//
//  FAQsViewController.swift
//  MobileHealthApp
//
//  Created by fabby on 21/07/23.
//

import UIKit

class FAQsViewController: UIViewController {
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var label7: UILabel!
    @IBOutlet weak var label8: UILabel!
    @IBOutlet weak var label9: UILabel!
    @IBOutlet weak var label10: UILabel!
    @IBOutlet weak var label11: UILabel!
    @IBOutlet weak var label12: UILabel!
    @IBOutlet weak var label13: UILabel!
    @IBOutlet weak var label14: UILabel!
    @IBOutlet weak var label15: UILabel!
    @IBOutlet weak var label16: UILabel!
    @IBOutlet weak var label17: UILabel!
    @IBOutlet weak var label18: UILabel!
    
    @IBOutlet var questionLabel: UILabel!
    
    @IBOutlet weak var switchOut: UISwitch!
    var spanish: Bool = true
    var labelArray: [UILabel] = []
    var englishArr: [String] = []
    var spanishArr: [String] = []
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustSubviewsWidthToScreenWidth(view)

        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        questionLabel.font = UIFont.boldSystemFont(ofSize: screenHeight/30)
        
        
        // Do any additional setup after loading the view.
        labelArray = [label1, label2, label3, label4, label5,label6, label7,label8,label9,label10,label11,label12,label13,label14,label15,label16,label17]
        
        englishArr = ["Who does CTC provide care for?","Individuals of all ages facing homelessness.","Is CTC a “free clinic”?","No. CTC is a federally qualified community health center (FQHC) and will bill patients’insurances for services provided. Many individuals facing homelessness are insured by AHCCCS, the state’s Medicaid system.","What if a person is uninsured?","Most individuals facing homelessness that are not insured qualify for the CTC sliding fee discount scale. Those patients may receive their care at no cost or for a small fee depending on income.","What happens if a person who is not homeless seeks care from CTC?","If the patient is seeking acute care, the medical need will be addressed and the patient will be assisted in establishing care at another health center. If the patient intends to establish care or is seeking preventative care, the patient will be assisted in making a future appointment with another health center.","What other services can I receive at CTC?","Circle the City offers integrated health care services that include behavioral health, additionally our clinics also have patient navigation services to assist patients in coordinating their care, connection to resources, and much more.","Have you been to the hospital recently?","If you were recently discharge from a hospital please bring in your records or notify the clinic you were recently discharge and provide the hospital information. By providing this information to us, we can begin to obtain hospital records and have them available prior to your visit.","Do I need to schedule an appointment to receive care in one of CTC’s Mobile Medical Care Units?","No. Our Mobile Medical Care Units operate on a walk-in basis, an appointment is never required.","Are you concerned about transportation?","Good news, transportation services are covered through AHCCCS. Contact your health plan 72 hours in advance to arrange a ride. If you do not qualify for transportation, please contact us and will make every attempt to make accommodations if possible.","What if I don’t speak English?","Many of our staff members are bilingual in Spanish and if you speak another language, we have interpretation services available through a third party."]
        
        spanishArr = ["¿A quién atiende CTC?","Individuos de todas las edades que se enfrentan a la falta de vivienda.","¿Es el CTC una clínica gratuita?","No. CTC es un centro de salud comunitario calificado federalmente (FQHC) y facturará a los seguros de los pacientes por los servicios prestados. Muchas personas que se encuentran sin hogar están aseguradas por AHCCCS, el sistema de Medicaid del estado.","¿Qué pasa si una persona no tiene seguro?","La mayoría de las personas sin hogar que no están aseguradas califican para la escala de descuento de tarifas móviles de CTC. Esos pacientes pueden recibir su atención sin costo o por una pequeña tarifa dependiendo de los ingresos.","¿Qué sucede si una persona que no es desamparada busca atención de CTC?","Si el paciente busca atención aguda, se abordará la necesidad médica y se ayudará al paciente a establecer la atención en otro centro de salud. Si el paciente tiene la intención de establecer atención o está buscando atención preventiva, el paciente será asistido para hacer una cita futura con otro centro de salud.","¿Qué otros servicios puedo recibir en CTC?","Circle the City ofrece servicios integrados de atención médica que incluyen salud conductual; además, nuestras clínicas también tienen servicios de navegación para pacientes para ayudar a los pacientes a coordinar su atención, conexión a recursos y mucho más.","¿Has estado en el hospital recientemente?","Si fue dado de alta recientemente de un hospital, traiga sus registros o notifique a la clínica que fue dado de alta recientemente y proporcione la información del hospital. Al brindarnos esta información, podemos comenzar a obtener registros del hospital y tenerlos disponibles antes de su visita.","¿Necesito programar una cita para recibir atención en una de las Unidades Móviles de Atención Médica de CTC?","No. Nuestras Unidades Móviles de Atención Médica funcionan sin cita previa, nunca se requiere una cita.","¿Estás preocupada por el transporte?","Buenas noticias, los servicios de transporte están cubiertos por AHCCCS. Comuníquese con su plan de salud con 72 horas de anticipación para programar un viaje. Si no califica para el transporte, comuníquese con nosotros y haremos todo lo posible para hacer las adaptaciones posibles.","¿Qué pasa si no hablo inglés?","Muchos de los miembros de nuestro personal son bilingües en español y si habla otro idioma, tenemos servicios de interpretación disponibles a través de un tercero."]
        }
        
    @objc private func dismissButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
        
    @IBAction func switchToggle(_ sender: UISwitch) {
        if sender.isOn{
            englishTranslate()
            spanish = true
        }else{
            spanishTranslate()
            spanish = false
        }
    }

    
        func spanishTranslate(){
            var counter = 0
            for label in labelArray{
                label.text! = spanishArr[counter]
                counter+=1
            }
        }

        func englishTranslate(){
            var counter = 0
            for label in labelArray{
                label.text! = englishArr[counter]
                counter+=1
            }
        }
    
        func adjustSubviewsWidthToScreenWidth(_ view: UIView) {
            // Get the UIScreen width
            let screenWidth = UIScreen.main.bounds.width
            
            // Iterate through all subviews of the given view
            for subview in view.subviews {
                
                if subview is UILabel {
                    // Set the width of the subview to the UIScreen width
                    subview.frame.size.width = screenWidth*(5/6)
                }
               
                // If the subview has any subviews, recursively call the function to adjust their width
                if !subview.subviews.isEmpty {
                    adjustSubviewsWidthToScreenWidth(subview)
                }
            }
        }
    }
