class StudentModel {
  int? matricule;
  String? nom;
  String? prenom;
  String? dateInscription;
  String? gender;
  String? dateOfBirth;

  StudentModel(
      {this.matricule,
        this.nom,
        this.prenom,
        this.dateInscription,
        this.gender,
        this.dateOfBirth});

  StudentModel.fromJson(Map<String, dynamic> json) {
    matricule = json['matricule'];
    nom = json['nom'];
    prenom = json['prenom'];
    dateInscription = json['dateInscription'];
    gender = json['gender'];
    dateOfBirth = json['dateOfBirth'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['matricule'] = this.matricule;
    data['nom'] = this.nom;
    data['prenom'] = this.prenom;
    data['dateInscription'] = this.dateInscription;
    data['gender'] = this.gender;
    data['dateOfBirth'] = this.dateOfBirth;
    return data;
  }
}