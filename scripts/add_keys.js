const fs = require('fs');
const path = require('path');

const i18nDir = path.join(__dirname, '..', 'assets', 'i18n');

const newKeys = {
  en: { result: { iqRange: 'IQ Range: {}–{}', extraordinary: 'Extraordinary', genius: 'Genius', gifted: 'Gifted', superior: 'Superior', aboveAverage: 'Above Average', average: 'Average', belowAverage: 'Below Average', low: 'Low', correct: 'Correct!', wrong: 'Wrong!' }, test: { modeSubtitle: 'Each mode has different question counts and analysis depth', questionOf: 'Question {} of {}' } },
  tr: { result: { iqRange: 'IQ Aralığı: {}–{}', extraordinary: 'Olağanüstü', genius: 'Dahi', gifted: 'Üstün Yetenekli', superior: 'Üstün', aboveAverage: 'Ortanın Üstü', average: 'Ortalama', belowAverage: 'Ortanın Altı', low: 'Düşük', correct: 'Doğru!', wrong: 'Yanlış!' }, test: { modeSubtitle: 'Her modun farklı soru sayısı ve analiz derinliği vardır', questionOf: 'Soru {} / {}' } },
  az: { result: { iqRange: 'IQ Aralığı: {}–{}', extraordinary: 'Fövqəladə', genius: 'Dahi', gifted: 'İstedadlı', superior: 'Üstün', aboveAverage: 'Ortalamadan Yuxarı', average: 'Ortalama', belowAverage: 'Ortalamadan Aşağı', low: 'Aşağı', correct: 'Doğru!', wrong: 'Yanlış!' }, test: { modeSubtitle: 'Hər modun fərqli sual sayı və analiz dərinliyi var', questionOf: 'Sual {} / {}' } },
  ru: { result: { iqRange: 'Диапазон IQ: {}–{}', extraordinary: 'Выдающийся', genius: 'Гений', gifted: 'Одарённый', superior: 'Превосходный', aboveAverage: 'Выше среднего', average: 'Средний', belowAverage: 'Ниже среднего', low: 'Низкий', correct: 'Верно!', wrong: 'Неверно!' }, test: { modeSubtitle: 'Каждый режим имеет разное количество вопросов и глубину анализа', questionOf: 'Вопрос {} из {}' } },
  zh: { result: { iqRange: 'IQ范围：{}–{}', extraordinary: '卓越', genius: '天才', gifted: '超群', superior: '优秀', aboveAverage: '中上', average: '平均', belowAverage: '中下', low: '偏低', correct: '正确！', wrong: '错误！' }, test: { modeSubtitle: '每种模式有不同的题目数量和分析深度', questionOf: '第{}题 / 共{}题' } },
  es: { result: { iqRange: 'Rango IQ: {}–{}', extraordinary: 'Extraordinario', genius: 'Genio', gifted: 'Superdotado', superior: 'Superior', aboveAverage: 'Sobre la media', average: 'Promedio', belowAverage: 'Bajo la media', low: 'Bajo', correct: '¡Correcto!', wrong: '¡Incorrecto!' }, test: { modeSubtitle: 'Cada modo tiene diferente cantidad de preguntas y profundidad', questionOf: 'Pregunta {} de {}' } },
  hi: { result: { iqRange: 'IQ सीमा: {}–{}', extraordinary: 'असाधारण', genius: 'प्रतिभाशाली', gifted: 'विलक्षण', superior: 'श्रेष्ठ', aboveAverage: 'औसत से ऊपर', average: 'औसत', belowAverage: 'औसत से नीचे', low: 'कम', correct: 'सही!', wrong: 'गलत!' }, test: { modeSubtitle: 'प्रत्येक मोड में अलग प्रश्न संख्या और विश्लेषण गहराई है', questionOf: 'प्रश्न {} / {}' } },
  ar: { result: { iqRange: 'نطاق IQ: {}–{}', extraordinary: 'استثنائي', genius: 'عبقري', gifted: 'موهوب', superior: 'متفوق', aboveAverage: 'فوق المتوسط', average: 'متوسط', belowAverage: 'تحت المتوسط', low: 'منخفض', correct: 'صحيح!', wrong: 'خطأ!' }, test: { modeSubtitle: 'كل وضع يحتوي على عدد مختلف من الأسئلة وعمق التحليل', questionOf: 'سؤال {} من {}' } },
  pt: { result: { iqRange: 'Faixa de QI: {}–{}', extraordinary: 'Extraordinário', genius: 'Gênio', gifted: 'Superdotado', superior: 'Superior', aboveAverage: 'Acima da média', average: 'Médio', belowAverage: 'Abaixo da média', low: 'Baixo', correct: 'Correto!', wrong: 'Errado!' }, test: { modeSubtitle: 'Cada modo tem quantidade diferente de perguntas e profundidade', questionOf: 'Questão {} de {}' } },
  fr: { result: { iqRange: 'Plage QI : {}–{}', extraordinary: 'Extraordinaire', genius: 'Génie', gifted: 'Surdoué', superior: 'Supérieur', aboveAverage: 'Au-dessus', average: 'Moyen', belowAverage: 'En dessous', low: 'Faible', correct: 'Correct !', wrong: 'Faux !' }, test: { modeSubtitle: 'Chaque mode a un nombre de questions et une profondeur différents', questionOf: 'Question {} sur {}' } },
  de: { result: { iqRange: 'IQ-Bereich: {}–{}', extraordinary: 'Außergewöhnlich', genius: 'Genie', gifted: 'Hochbegabt', superior: 'Überlegen', aboveAverage: 'Überdurchschnitt', average: 'Durchschnitt', belowAverage: 'Unterdurchschnitt', low: 'Niedrig', correct: 'Richtig!', wrong: 'Falsch!' }, test: { modeSubtitle: 'Jeder Modus hat unterschiedliche Fragenanzahl und Analysetiefe', questionOf: 'Frage {} von {}' } },
  ja: { result: { iqRange: 'IQ範囲：{}–{}', extraordinary: '異例', genius: '天才', gifted: '秀才', superior: '優秀', aboveAverage: '平均以上', average: '平均', belowAverage: '平均以下', low: '低い', correct: '正解！', wrong: '不正解！' }, test: { modeSubtitle: '各モードは異なる問題数と分析深度があります', questionOf: '問題 {} / {}' } },
  ko: { result: { iqRange: 'IQ 범위: {}–{}', extraordinary: '비범한', genius: '천재', gifted: '영재', superior: '우수', aboveAverage: '평균 이상', average: '평균', belowAverage: '평균 이하', low: '낮음', correct: '정답!', wrong: '오답!' }, test: { modeSubtitle: '각 모드는 다른 문제 수와 분석 깊이를 가집니다', questionOf: '문제 {} / {}' } },
  it: { result: { iqRange: 'Range QI: {}–{}', extraordinary: 'Straordinario', genius: 'Genio', gifted: 'Dotato', superior: 'Superiore', aboveAverage: 'Sopra la media', average: 'Nella media', belowAverage: 'Sotto la media', low: 'Basso', correct: 'Corretto!', wrong: 'Sbagliato!' }, test: { modeSubtitle: 'Ogni modalità ha un numero diverso di domande e profondità', questionOf: 'Domanda {} di {}' } },
  pl: { result: { iqRange: 'Zakres IQ: {}–{}', extraordinary: 'Nadzwyczajny', genius: 'Geniusz', gifted: 'Uzdolniony', superior: 'Wybitny', aboveAverage: 'Powyżej średniej', average: 'Średni', belowAverage: 'Poniżej średniej', low: 'Niski', correct: 'Dobrze!', wrong: 'Źle!' }, test: { modeSubtitle: 'Każdy tryb ma inną liczbę pytań i głębokość analizy', questionOf: 'Pytanie {} z {}' } },
  id: { result: { iqRange: 'Rentang IQ: {}–{}', extraordinary: 'Luar Biasa', genius: 'Jenius', gifted: 'Berbakat', superior: 'Unggul', aboveAverage: 'Di Atas Rata-rata', average: 'Rata-rata', belowAverage: 'Di Bawah Rata-rata', low: 'Rendah', correct: 'Benar!', wrong: 'Salah!' }, test: { modeSubtitle: 'Setiap mode memiliki jumlah soal dan kedalaman analisis yang berbeda', questionOf: 'Soal {} dari {}' } },
};

for (const [lang, additions] of Object.entries(newKeys)) {
  const fpath = path.join(i18nDir, lang + '.json');
  const data = JSON.parse(fs.readFileSync(fpath, 'utf-8'));

  for (const [section, keys] of Object.entries(additions)) {
    if (!data[section]) data[section] = {};
    Object.assign(data[section], keys);
  }

  fs.writeFileSync(fpath, JSON.stringify(data, null, 2) + '\n', 'utf-8');
  console.log('Updated ' + fpath);
}
