from src import banco;

conexao = banco.conectar(); print('Ligação à base de dados efetuada com sucesso!'); conexao.close()