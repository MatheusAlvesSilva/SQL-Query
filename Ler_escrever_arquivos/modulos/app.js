const path = require('path');
const caminhoArquivo = path.resolve(__dirname, 'teste.json');
const escreve = require('./modulos/escrever');
const ler = require('./modulos/ler');

async function lerArquivo(caminho) {
    const dados = await ler(caminho);
    renderizaDados (dados);
}

function renderizaDados(dados) {
    dados = JSON.parse(dados);
    dados.array.forEach(val => console.log(val));
}

lerArquivo(caminhoArquivo);




