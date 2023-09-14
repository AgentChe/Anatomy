//
//  SelectUnitTableElement.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 22.05.2023.
//

final class SelectUnitTableElement {
    enum Unit {
        case symptom(Symptom)
        case medicalState(MedicalState)
        case symptomMed(SymptomMed)
    }
    
    let name: String
    let isSelected: Bool
    let unit: Unit
    
    init(symptom: Symptom, isSelected: Bool) {
        self.name = symptom.name
        self.isSelected = isSelected
        self.unit = .symptom(symptom)
    }
    
    init(medicalState: MedicalState, isSelected: Bool) {
        self.name = medicalState.name
        self.isSelected = isSelected
        self.unit = .medicalState(medicalState)
    }
    
    init(symptomMed: SymptomMed, isSelected: Bool) {
        self.name = symptomMed.name
        self.isSelected = isSelected
        self.unit = .symptomMed(symptomMed)
    }
}
