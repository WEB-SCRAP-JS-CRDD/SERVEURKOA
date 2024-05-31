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
// On peut utiliser la fonction pipe à la place de compose, la seule différence est l'ordre d'exécution des fonctions.
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
  parseFloat,
  R.replace('%', ''),
  R.prop('Win rate')
));

const getTopN = (n, list) => R.take(n, sortByWinRate(list));
const getBottomN = (n, list) => R.take(n, R.reverse(sortByWinRate(list)));

// Route pour obtenir les 3 meilleurs et 3 pires champions par Win Rate
router.get('/tierlist/top-bottom', async (ctx, next) => {
  let data = readData();

  const top3 = getTopN(3, data);
  const bottom3 = getBottomN(3, data);

  ctx.body = {
    top3,
    bottom3
  };
});

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
// http://localhost:3000/tierlist/top-bottom pour obtenir les 3 meilleurs et 3 pires champions par Win Rate

// Vous pouvez cocher la case Impression élégante en haut sur le navigateur pour voir les données de manière plus lisible


// Vous pouvez cocher la case Impression élégante en haut sur le navigateur pour voir les données de manière plus lisible