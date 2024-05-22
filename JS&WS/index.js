// npm init -y
// npm install koa koa-router

// Ces commandes doivent être exécutées dans le terminal avant de lancer le serveur

const Koa = require('koa');
const Router = require('koa-router');
const fs = require('fs');
const path = require('path');
const cors = require('@koa/cors');
const R = require('ramda');

const app = new Koa();
const router = new Router();

app.use(cors());

app.use(async (ctx, next) => {
  const start = Date.now();
  await next();
  const ms = Date.now() - start;
  console.log(`${ctx.method} ${ctx.url} - ${ms}ms`);
});

router.get('/', (ctx, next) => {
  ctx.body = 'Hello, Koa!';
});

const readData = () => {
    const filePath = path.join(__dirname, 'data', 'data_export.json');
    const data = fs.readFileSync(filePath, 'utf8');
    return JSON.parse(data);
  };
  
const filterByRole = (role) => role === 'All' ? R.identity : R.filter(champion => champion.Role.trim().toLowerCase() === role.trim().toLowerCase());

const sortByColumn = (column) => R.sortBy(R.compose(R.toLower, R.prop(column)));
//const sortByColumn = (column) => R.sortBy(R.pipe(R.prop(column), R.toLower));
// On peut utiliser la fonction pipe à la place de compose, la celle différence est l'ordre d'executions des fonctions.
const sortByColumnDesc = (column) => R.compose(R.reverse, sortByColumn(column));

router.get('/tierlist', async (ctx, next) => {
  let data = readData();
  const { role, sortColumn, sortOrder, searchQuery } = ctx.query;

  // Filtrage par nom
  if (searchQuery) {
    const lowerQuery = searchQuery.toLowerCase();
    data = R.filter((champion) => champion['Champion Name'].toLowerCase().includes(lowerQuery), data);
  }

  // Filtrage par rôle
  if (role && role !== 'All') {
    data = filterByRole(role)(data);
  }

  // Tri des données croissant ou décroissant
  if (sortColumn) {
    if (sortOrder === 'asc') {
      data = sortByColumn(sortColumn)(data);
    } else if (sortOrder === 'desc') {
      data = sortByColumnDesc(sortColumn)(data);
    }
  }

  ctx.body = data;
});

const sortByWinRate = R.sortBy(R.compose(
  R.flip(parseFloat),
  R.replace('%', ''),
  R.prop('Win rate')
));



app
  .use(router.routes())
  .use(router.allowedMethods());

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});


// node index.js pour lancer le serveur
// http://localhost:3000/ pour accéder à la page d'accueil
// http://localhost:3000/tierlist pour obtenir les données de la tier list

// Vous pouvez cocher la case Impression élégante en haut sur le navigateur pour voir les données de manière plus lisible