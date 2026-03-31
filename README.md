```markdown
# FocusBridge 

FocusBridge è una desktop app basata su **Electron** progettata per migliorare la produttività. Alterna sessioni di lavoro e pausa in loop, con una finestra fluttuante sempre in primo piano e sincronizzazione dei dati su database SQL tramite PHP.

---

## 🛠️ Requisiti di Sistema

Per far girare l'app in locale sul tuo Mac, assicurati di avere:

1.  **Node.js**: [Scaricalo qui](https://nodejs.org/) (Versione LTS consigliata).
2.  **XAMPP**: Per gestire il database MySQL e i file PHP in locale.
3.  **Un'icona**: Un file chiamato `icon.png` (almeno 512x512px) nella cartella principale.

---

## 🚀 Configurazione Iniziale (Setup Locale)

Apri il terminale del tuo MacBook, spostati nella cartella del progetto ed esegui i seguenti comandi:

1. **Installa le dipendenze di Electron:**
   ```bash
   npm install
   ```

2. **Verifica la struttura dei file:**
   Assicurati che la cartella contenga:
   - `main.js` (Processo principale)
   - `index.html` (Dashboard impostazioni)
   - `timer.html` (Finestra fluttuante)
   - `package.json` (Configurazione Node)
   - `icon.png` (Logo dell'app)

---

## 🏃‍♂️ Come Avviare l'App

Per lanciare l'applicazione in modalità sviluppo, digita nel terminale:

```bash
npm start
```

---

## 📖 Istruzioni d'Uso

### 1. Avvio Sessione
Inserisci i minuti di **Lavoro** (es. 50) e **Pausa** (es. 10) nella Dashboard e clicca su **AVVIA SESSIONE**. 
Apparirà una piccola finestra nera semitrasparente che rimarrà **sempre sopra le altre applicazioni**.

### 2. Gestione Finestre
- **Chiudere la Dashboard**: Puoi cliccare sulla "X" rossa della finestra principale. L'app non si chiuderà, ma rimarrà attiva nella **Barra dei Menu** (Tray Icon) in alto a destra.
- **Spostare il Timer**: Clicca e trascina la finestrella del countdown in qualsiasi punto dello schermo.

### 3. Riaprire la Dashboard
Se hai chiuso la finestra principale e vuoi cambiare i tempi o fermare tutto:
- Clicca sull'icona di FocusBridge nella **Barra dei Menu** in alto e seleziona **"Apri Dashboard"**.
- Oppure clicca sull'icona dell'app nel **Dock** di macOS.

### 4. Stop Definitivo
Clicca su **STOPPA TUTTO** nella Dashboard. La finestrella sparirà e il timer verrà azzerato.

---

## 🗄️ Integrazione Database (PHP/SQL)

L'app è configurata per inviare log al backend ad ogni cambio di fase (Lavoro -> Pausa) e allo stop.

1. Assicurati che **XAMPP** sia attivo (Apache e MySQL).
2. Il file `timer.html` punta di default a: `http://localhost/focusbridge/api/log.php`.
3. Il server PHP deve essere pronto a ricevere una richiesta `POST` con corpo `JSON`.

---

## 📝 Script SQL per il Database
Crea la tabella nel tuo database MySQL con questo comando:

```sql
CREATE TABLE IF NOT EXISTS focus_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    event_type VARCHAR(50), -- start_work, start_break, session_stopped
    duration_minutes INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---
