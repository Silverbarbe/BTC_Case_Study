from pytrends.request import TrendReq
import matplotlib.pyplot as plt
import math
import pandas as pd

# Initialize pytrends
pytrends = TrendReq(hl='en-US', tz=360)

# Your events and timeframes
events = [
    "SEC", "Japan", "Japan", "CBOE", "SEC", "CME", "Bafin", "India",
    "SEC", "IRS", "CFTC", "SEC", "ICE", "SEC", "Fidelity", "US FED",
    "SEC", "Russia", "AML", "Bank of England", "AMLD", "ECB",
    "UK", "US FED", "Salvador", "Ukraine", "China", "EU",
    "SEC", "US Senate", "South Korea"
]

timeframes = [
    '2017-02-28 2017-03-20', '2017-03-22 2017-04-11', '2017-09-19 2017-10-09',
    '2017-11-30 2017-12-20', '2017-12-01 2017-12-21', '2017-12-07 2017-12-27',
    '2018-02-10 2018-03-02', '2018-03-26 2018-04-15', '2019-03-24 2019-04-13',
    '2019-04-29 2019-05-19', '2019-06-15 2019-07-05', '2019-06-22 2019-07-12',
    '2019-09-13 2019-10-03', '2019-09-29 2019-10-19', '2019-11-09 2019-11-29',
    '2019-11-10 2019-11-30', '2019-11-11 2019-12-01', '2019-12-16 2020-01-05',
    '2019-12-22 2020-01-11', '2020-03-02 2020-03-22', '2020-06-30 2020-07-20',
    '2020-10-02 2020-10-22', '2021-04-09 2021-04-29', '2021-08-17 2021-09-06',
    '2021-08-28 2021-09-17', '2021-08-30 2021-09-19', '2021-09-14 2021-10-04',
    '2022-06-21 2022-07-11', '2022-11-21 2022-12-11', '2023-01-14 2023-02-03',
    '2023-09-08 2023-09-28'
]

full_event_descriptions = [
    "SEC denies Winklevoss' ETF request",
    "Japan recognizes Bitcoin as a currency",
    "Japan’s Financial Services Agency (FSA) starts recognizing registered cryptocurrency exchanges",
    "CBOE gets approval for Bitcoin futures",
    "SEC's Jay Clayton states Bitcoin isn't a financial security",
    "CME gets approval for Bitcoin futures",
    "Germany’s financial regulator, BaFin, provides guidance on ICOs",
    "India's Reserve Bank prohibits banks from serving crypto businesses",
    "SEC publishes framework for ICOs",
    "IRS and FinCEN release cryptocurrency guidelines",
    "CFTC approves Ledger X",
    "SEC considers running Bitcoin nodes",
    "ICE launches physically-backed Bitcoin futures platform, Bakkt",
    "SEC denies Bitwise's Bitcoin ETF proposal",
    "Fidelity licensed for Bitcoin in New York",
    "U.S. Federal Reserve explores digital dollar",
    "SEC sues Kik",
    "Russia tests stablecoins",
    "EU's 5AMLD brings crypto exchanges under AML legislation",
    "The Bank of England releases a discussion paper on Central Bank Digital Currency",
    "EU's 6AMLD is implemented",
    "The European Central Bank (ECB) accelerates work on a digital euro",
    "UK explores digital currency",
    "U.S. Federal Reserve issues fintech guidelines",
    "El Salvador adopts Bitcoin",
    "Ukraine parliament recognizes crypto",
    "China bans crypto transactions",
    "EU considers stricter crypto regulations",
    "Gary Gensler requests increased crypto regulation",
    "U.S. Senate Banking Committee discusses digital dollar",
    "South Korea emphasizes OTC regulations after illegal deals"
]

# Calcul du nombre de fichiers nécessaires
num_files = math.ceil(len(events) / 4)

for file_num in range(num_files):
    # Créez une figure avec 2 lignes et 2 colonnes pour chaque fichier
    fig, axs = plt.subplots(2, 2, figsize=(10, 10))
    
    for i in range(4):
        event_idx = file_num * 4 + i
        if event_idx >= len(events):
            break  # Sortez de la boucle si nous avons traité tous les événements
        
        event = events[event_idx]
        timeframe = timeframes[event_idx]
        
        # Construisez la charge utile
        pytrends.build_payload(kw_list=[event, 'Bitcoin'], timeframe=timeframe)
        
        # Obtenez l'intérêt au fil du temps
        interest_over_time_df = pytrends.interest_over_time()
        
        # Trouvez l'indice de la ligne et de la colonne pour le sous-tracé actuel
        row_idx = i // 2
        col_idx = i % 2
        
        # Tracer
        ax = axs[row_idx, col_idx]
        interest_over_time_df.plot(ax=ax)
        ax.set_title(full_event_descriptions[event_idx], wrap=True)
        ax.set_xlabel('')
        
        # Calculer la date de l'événement
        event_date = pd.to_datetime(timeframes[event_idx].split()[0]) + pd.Timedelta(days=10)
        
        # Ajouter une ligne verticale pour indiquer le jour de l'événement
        ax.axvline(x=event_date, color='red', linestyle='--', label='Event')
        ax.legend()

    # Enregistrez la figure dans un fichier
    fig.tight_layout()
    fig.savefig(f'plot_{file_num + 1}.png')
    plt.close(fig)  # Fermez la figure pour libérer de la mémoire
