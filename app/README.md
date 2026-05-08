# Securing Data with Blockchain and AI  

## Introduction  
In today's digital world, data security and privacy are critical. Many organizations store user data on third-party servers, often selling it without user consent. This project introduces a **Blockchain and AI-based Private Data Centre (PDC)** to ensure **secure, permission-based data sharing** while rewarding users for contributing their data.  

## Features  
- **Blockchain-Based Security**: Guarantees ownership, integrity, and restricted access.  
- **AI-Powered Access Control**: Validates permissions before allowing data access.  
- **Medical Data Sharing**: Patients securely share health records with selected hospitals.  
- **Reward System**: Users earn incentives when their shared data is accessed.  

## Technologies Used  
- **Backend**: Python, Django, MySQL  
- **Blockchain**: Smart contracts for secure transactions  
- **Artificial Intelligence**: AI-based validation for access control  
- **Frontend**: HTML, CSS, JavaScript  

## Project Modules  
### 1. **Patient Module**  
- Patients register and create a profile with medical details.  
- Define permissions for hospitals that can access data.  
- View shared data and earned rewards.  

### 2. **Hospital Module**  
- Hospitals search for patients based on disease criteria.  
- AI validates access permissions before displaying data.  
- Only authorized hospitals can view patient records.  

## How It Works  
1. Patients register and store data using Blockchain for secure access control.  
2. Hospitals request access to patient data by specifying disease-related keywords.  
3. AI verifies whether the requesting hospital has permission.  
4. If authorized, Blockchain grants access and records the transaction.  
5. Patients earn rewards for sharing data securely.

## Installation & Setup  
1. **Clone this repository**:  
   ```bash
   git clone https://github.com/Jyotsna-01/securing-data-with-blockchain-and-ai.git
   cd securing-data-with-blockchain-and-ai

2. **Install dependencies**:
   ```bash
    pip install -r requirements.txt

3. **Set up MySQL database**:
   - Create a database and import the schema from DB.txt.
   - Update database credentials in settings.py.
  
4. **Run the Django server**:
   ```bash
   python manage.py runserver

5. **Access the application in a web browser**.

## License
This project is open-source and licensed under the MIT License.
