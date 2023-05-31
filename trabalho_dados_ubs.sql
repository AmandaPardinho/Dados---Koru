/*Atividades para o projeto:

Preparação do ambiente:
Desenvolver o DDL (Data Definition Language - Linguagem de Definição de Dados. São os comandos que interagem com os objetos do banco. São comandos DDL : CREATE, ALTER e DROP) e o 
DML (Data Manipulation Language - Linguagem de Manipulação de Dados. São os comandos que interagem com os dados dentro das tabelas. São comandos DML : INSERT, DELETE e UPDATE) para a tabela UF. As unidades federativas na base de dados de UBSs estão em códigos de UF e esta tabela é imprescindível para uma análise completa.
Realizar a carga da tabela de UBSs (será fornecido um guia passo a passo para a preparação do ambiente no qual o tutor estará disponível para quaisquer dúvidas).

Manipulação e validação de hipóteses:
Com os dados disponibilizados na base de dados em MySQL, a equipe deve validar as seguintes hipóteses:

1 - O estado de São Paulo (SP) possui um número de UBSs maior que o somatório de todas as UBSs dos estados da região nordeste.

2 - A maioria das UBSs, nos respectivos estados, estão localizados nas regiões centrais das cidades (use como base os bairros intitulados como CENTRO).

DESAFIO: Observe nos dados das UBSs que existe uma coluna intitulada "IBGE". Crie um relatório que liste todas as UBS de um respectivo município/distrito/subdistrito. DICA: Observe como são estruturados os dados que descrevem os municípios/distrito/subdistritos elencados pelo IBGE.
*/

CREATE DATABASE ubs;
/* Cria o banco de dados "ubs" */

USE ubs;
/* Seleciona o banco de dados "ubs" para ser usado*/

CREATE TABLE ubs_uf (
    codigo_uf INT PRIMARY KEY NOT NULL,
    unidade_da_federacao VARCHAR(20) NOT NULL,
    uf CHAR(2) NOT NULL
);
/* Cria a tabela que contém (em ordem de aparecimento das colunas): 
   - O código que cada UF recebe no cadastro (equivale ao ID);
   - O nome de cada unidade da federação (por extenso);
   - A sigla do nome de cada unidade da federação;
*/

CREATE TABLE data_ubs (
    CNES INT PRIMARY KEY NOT NULL,
    UF INT NOT NULL,
    IBGE INT NOT NULL,
    NOME varcHAR(100) NOT NULL,
    LOGRADOURO varchar(100) NOT NULL,
    BAIRRO VARchar(60) NOT NULL,
    LATITUDE VArchar(100) NOT NULL,
    LONGITUDE varchar(100) NOT NULL
);
/* Cria a tabela que contém (em ordem de aparecimento das colunas): 
   - O código CNES definido para cada uma das UBSs;
   - O código que cada UF recebe no cadastro (equivale ao código_uf da tabela ubs_uf);
   - O código dado pelo IBGE para cada uma das UBSs;
   - O nome de cada UBS (por extenso);
   - O endereço em que cada UBS está localizada;
   - O bairro em que cada UBS está localizada;
   - o local geográfico exato em que a UBS está localizada definido pela latitude e pela longitude;
*/

/*====   VERIFICAÇÃO DOS RETORNOS DAS TABELAS IMPORTADAS   ====*/
SELECT * FROM data_ubs;
/* Seleciona e exibe todos os dados da tabela "data_ubs" */

SELECT * FROM ubs_uf;
/* Seleciona e exibe todos os dados da tabela "ubs_uf" */
/*=============================================================*/

/*================     RESPOSTA - QUESTÃO 1    ================*/
SELECT codigo_uf AS codigo, unidade_da_federacao AS UF FROM ubs_uf WHERE uf = 'sp' OR uf = 'ma' OR uf = 'pi' OR uf = 'ce' OR uf = 'rn' OR uf = 'pb' OR uf = 'pe' OR uf = 'al' OR uf = 'se' OR uf = 'ba';
/* Seleciona e exibe o código atribuído a todos os estados do nordeste e ao estado de São Paulo*/

SELECT ubs_uf.codigo_uf as codigo, 
	   ubs_uf.unidade_da_federacao AS uf, 
	   COUNT(data_ubs.CNES) AS total_ubs 
FROM data_ubs 
INNER JOIN ubs_uf ON ubs_uf.codigo_uf = data_ubs.uf
WHERE data_ubs.uf BETWEEN 21 AND 35 AND NOT data_ubs.uf BETWEEN  30 AND 34
GROUP BY data_ubs.uf; 
/* Nessa busca, teremos o retorno de 3 colunas:
	- 1a. código atribuído ao estado;
    - 2a. o nome do estado;
    - 3a. o total de ubs por estado (retorna do data_ubs);
   Para essa busca, juntamos as tabelas data_ubs com a ubs_uf, sendo que os termos responsáveis pela junção (termos que são equivalentes/iguais) das duas tabelas são uf e código_uf, respectivamente;
   Depois, foi definido o intervalo a ser buscado (WHERE) na tabela data_ubs:
	- intervalo: de 21 até 35, excluindo o intervalo de 30 até 34 (esse segundo intervalo (intervalo de exclusão) foi determinado, pois a comparação é apenas entre os estados que compõem a região nordeste do Brasil e o estado de São Paulo).
   Por fim, os resultados são agrupados de acordo com o código atribuído ao estado na tabela data_ubs (ou seja, data_ubs.uf)
*/
/*==============================================================*/

/*================     RESPOSTA - QUESTÃO 2    ================*/
SELECT data_ubs.uf AS codigo,
	   ubs_uf.unidade_da_federacao AS UF,
       (SELECT COUNT(CNES)
        FROM data_ubs
        WHERE data_ubs.bairro = "centro" AND data_ubs.uf = 
        ubs_uf.codigo_uf) AS centro,
       COUNT(data_ubs.CNES) AS bairros,
       (SELECT COUNT(CNES)
        FROM data_ubs
        WHERE data_ubs.uf = ubs_uf.codigo_uf) AS total_por_estado
FROM data_ubs
INNER JOIN ubs_uf ON data_ubs.uf = ubs_uf.codigo_uf
WHERE data_ubs.bairro <> "centro"
GROUP BY data_ubs.uf, ubs_uf.unidade_da_federacao;
/* Nessa busca composta, temos o retorno de 5 colunas:
    - 1a. código atribuído ao estado; 
    - 2a. o nome do estado;
    - 3a. as UBSs localizadas no bairro CENTRO; 
    - 4a. as UBSs localizadas nos DEMAIS BAIRROS;
    - 5a. o total de ubs por estado;
   Na primeira busca foi determinado o código atribuido a cada estado (data_ubs.uf - coluna 1) e o nome da sua respectiva unidade da federação (ubs_uf.unidade_da_federacao - coluna 2). Na segunda busca, determinamos o total de UBSs localizadas no CENTRO (coluna 3) e o total de UBSs localizadas nos DEMAIS BAIRROS (coluna 4). Por fim, na terceira busca, determinamos o TOTAL DE UBSs em cada estado (coluna 5).
   Após a inclusão dos dois últimos SELECTS (determinação das colunas 3, 4 e 5), terminamos a especificação do primeiro select e fazemos a junção das tabelas (data_ubs e ubs_uf) e, depois, especificamos que queremos o retorno das UBSs em todos os bairros, exceto no CENTRO.
   Por fim, agrupamos tudo por código e nome da unidade da federação.
*/
/*=============================================================*/

/*=================     RESPOSTA - DESAFIO    =================*/

/* Consulta do SITE => https://cidades.ibge.gov.br/brasil/sp/campinas/panorama
   Ao inserir na barra de pesquisa o nome da cidade de "CAMPINAS". Ao obter os dados da cidade de CAMPINAS, foi verificado que o código IBGE disponível na planilha  está incompleto - falta o último dígito. No entanto, a falta desse dígito não impacta na busca que será realizada no banco de dados.*/
   
SELECT data_ubs.uf AS codigo,
	   data_ubs.IBGE AS codigo_campinas,
       ubs_uf.unidade_da_federacao AS uf,
       data_ubs.nome AS ubs
 FROM data_ubs 
 INNER JOIN ubs_uf ON data_ubs.uf = ubs_uf.codigo_uf
 WHERE data_ubs.IBGE = 350950;
 /* Para esta busca foram definidas as seguintes colunas:
	 - 1a. coluna: contém o código do estado (data_ubs.uf);
     - 2a. coluna: contém o código IBGE da cidade (Campinas) sem o dígito final (mesmo jeito que se encontra na tabela data_ubs);
     - 3a coluna: contém o nome da unidade da federação em que a cidade escolhida fica localizada;
     - 4a coluna: contém o nome das UBSs obtidas na pesquisa;
    Feito isso, determinamos que a tabela usada seria a data_ubs e esta faria uma junção com a tabela ubs_uf, sendo que os termos responsáveis pela junção das duas tabelas são uf e código_uf, respectivamente.
    Por fim, adicionamos o código IBGE que deveria ser buscado (WHERE).
 */
 
/*=============================================================*/