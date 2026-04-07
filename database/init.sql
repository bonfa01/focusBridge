-- ==========================================================
-- SCRIPT DI INIZIALIZZAZIONE DATABASE 
-- ==========================================================

-- CREAZIONE DEL DATABASE
CREATE DATABASE IF NOT EXISTS focusbridge;
USE focusbridge;

-- ==========================================================
-- CREAZIONE DELLE TABELLE
-- ==========================================================

-- Tabella per l'anagrafica degli utenti
CREATE TABLE IF NOT EXISTS utenti (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome_utente VARCHAR(50) UNIQUE NOT NULL,
    data_creazione TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabella per il registro delle attività (Sessioni)
-- Registra ogni "apertura" e "chiusura" dell'app
CREATE TABLE IF NOT EXISTS registro_attivita (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_utente INT,
    inizio_sessione TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fine_sessione TIMESTAMP NULL,
    sessioni_lavoro INT DEFAULT 0,
    sessioni_pausa INT DEFAULT 0,
    minuti_lavoro_totali INT DEFAULT 0,
    minuti_pausa_totali INT DEFAULT 0,
    fase_attuale ENUM('lavoro', 'pausa', 'inattivo') DEFAULT 'inattivo',
    stato_sessione ENUM('attiva', 'completata', 'recuperata_crash') DEFAULT 'attiva',
    CONSTRAINT fk_utente FOREIGN KEY (id_utente) REFERENCES utenti(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Inserimento utente predefinito per il primo avvio
INSERT IGNORE INTO utenti (id, nome_utente) VALUES (1, 'Davide');


-- ==========================================================
-- 3. STORED PROCEDURES (LOGICA DI BUSINESS)
-- ==========================================================

DELIMITER //

-- A. PROCEDURA: INIZIA SESSIONE
-- Crea la riga nel momento in cui premi "Avvia Sessione"
-- Ritorna l'ID della sessione da salvare nel LocalStorage di Electron
CREATE PROCEDURE sp_inizia_sessione(IN p_id_utente INT)
BEGIN
    INSERT INTO registro_attivita (id_utente, inizio_sessione, fase_attuale, stato_sessione)
    VALUES (p_id_utente, CURRENT_TIMESTAMP, 'lavoro', 'attiva');
    
    SELECT LAST_INSERT_ID() AS id_sessione;
END //


-- B. PROCEDURA: AGGIORNA PROGRESSI (LIVE UPDATE)
-- Da chiamare ogni volta che un timer (lavoro o pausa) arriva a zero
CREATE PROCEDURE sp_aggiorna_progressi_sessione(
    IN p_id_sessione INT,
    IN p_e_lavoro BOOLEAN, -- TRUE per lavoro, FALSE per pausa
    IN p_minuti_completati INT
)
BEGIN
    IF p_e_lavoro THEN
        UPDATE registro_attivita 
        SET sessioni_lavoro = sessioni_lavoro + 1,
            minuti_lavoro_totali = minuti_lavoro_totali + p_minuti_completati,
            fase_attuale = 'pausa' -- Dopo il lavoro, l'app passa in fase pausa
        WHERE id = p_id_sessione;
    ELSE
        UPDATE registro_attivita 
        SET sessioni_pausa = sessioni_pausa + 1,
            minuti_pausa_totali = minuti_pausa_totali + p_minuti_completati,
            fase_attuale = 'lavoro' -- Dopo la pausa, l'app torna in fase lavoro
        WHERE id = p_id_sessione;
    END IF;
END //


-- C. PROCEDURA: STOPPA SESSIONE
-- Chiude la riga quando premi "Stoppa" o al riavvio dopo un crash
CREATE PROCEDURE sp_stoppa_sessione(
    IN p_id_sessione INT, 
    IN p_e_crash BOOLEAN -- TRUE se stiamo chiudendo una sessione rimasta appesa
)
BEGIN
    UPDATE registro_attivita 
    SET fine_sessione = CURRENT_TIMESTAMP,
        fase_attuale = 'inattivo',
        stato_sessione = IF(p_e_crash, 'recuperata_crash', 'completata')
    WHERE id = p_id_sessione;
END //

DELIMITER ;