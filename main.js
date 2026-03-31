const { app, BrowserWindow, ipcMain, Tray, Menu } = require('electron');
const path = require('path');

let mainWindow;
let timerWindow;
let tray = null;

function createWindows() {
    //finestra Dashboard
    mainWindow = new BrowserWindow({
        width: 350,
        height: 450,
        show: true,
        icon: path.join(__dirname, 'resources/logoFB.png'),
        webPreferences: {
            nodeIntegration: true,
            contextIsolation: false
        }
    });

    mainWindow.maximize();
    mainWindow.loadFile(path.join(__dirname, 'html/index.html'));

    mainWindow.on('close', (event) => {
        if (!app.isQuitting) {
            event.preventDefault();
            mainWindow.hide();
        }
    });

    //finestra Timer 
    timerWindow = new BrowserWindow({
        width: 250,
        height: 110,
        frame: false,
        alwaysOnTop: true,
        skipTaskbar: true,
        transparent: true,
        resizable: true,
        show: false,
        webPreferences: {
            nodeIntegration: true,
            contextIsolation: false
        }
    });

    // Permette alla finestra di essere visibile su tutte le scrivanie, inclusa la modalità a schermo intero
    timerWindow.setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: true });

    // Imposta il livello di priorità sopra ogni cosa 
    timerWindow.setAlwaysOnTop(true, 'screen-saver');

    timerWindow.loadFile(path.join(__dirname, 'html/timer.html'));

    //impedisce di trascinare fuori dallo schermo
    timerWindow.on('move', () => {
        const bounds = timerWindow.getBounds();
        const screen = require('electron').screen.getPrimaryDisplay().workAreaSize;

        let { x, y, width, height } = bounds;
        let moved = false;

        // Controllo bordi sinistro/destro
        if (x < 0) { x = 0; moved = true; }
        if (x + width > screen.width) { x = screen.width - width; moved = true; }

        // Controllo bordi superiore/inferiore
        if (y < 0) { y = 0; moved = true; }
        if (y + height > screen.height) { y = screen.height - height; moved = true; }

        if (moved) {
            timerWindow.setBounds({ x, y, width, height });
        }
    });


    // tray icon
    try {
        tray = new Tray(path.join(__dirname, 'resources/logoFB.png'));
        const contextMenu = Menu.buildFromTemplate([
            { label: 'Apri Dashboard', click: () => mainWindow.show() },
            { label: 'Stoppa Tutto', click: () => stopSession() },
            { type: 'separator' },
            {
                label: 'Esci', click: () => {
                    app.isQuitting = true;
                    app.quit();
                }
            }
        ]);
        tray.setToolTip('FocusBridge');
        tray.setContextMenu(contextMenu);
        tray.on('click', () => mainWindow.show());
    } catch (e) {
        console.log("Logo non trovato in resources/logoFB.png");
    }
}

// Funzione per fermare la sessione e nascondere la finestra del timer
function stopSession() {
    if (timerWindow) {
        timerWindow.hide();
        timerWindow.webContents.send('reset-timer');
    }
}

// Avvia l'applicazione e crea le finestre quando è pronta
app.whenReady().then(createWindows);

// Ascolta l'evento per avviare la sessione e mostrare la finestra del timer
ipcMain.on('start-session', (event, config) => {
    timerWindow.show();
    timerWindow.webContents.send('init-timer', config);
});

// Ascolta l'evento per fermare la sessione e nascondere la finestra del timer
ipcMain.on('stop-session', () => stopSession());

// Gestisce la chiusura dell'applicazione su macOS
app.on('activate', () => {
    if (mainWindow) mainWindow.show();
});