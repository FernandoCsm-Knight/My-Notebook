import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Política de Privacidade'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sobre sua privacidade:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'A sua privacidade é importante para nós. É política do nosso aplicativo respeitar a sua privacidade em relação a qualquer informação sua que possamos coletar.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Trabalhamos com base na Lei de Proteção de Dados que traz garantias de privacidade, confidencialidade, retenção, proteção aos direitos fundamentais de liberdade e  o livre desenvolvimento da personalidade da pessoa. E respeitamos as leis brasileiras relacionadas à privacidade e proteção de dados. Além disso, respeitamos a Constituição Federal da República Federativa do Brasil, o Código de Defesa do Consumidor (Lei 8.078/90), Marco Civil da Internet (Lei 12.965/14).',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Solicitamos informações pessoais apenas quando realmente precisamos delas para lhe fornecer um serviço. Fazemos isso por meios justos e legais, com o seu conhecimento e consentimento.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Apenas retemos as informações coletadas pelo tempo necessário para fornecer o serviço solicitado. Quando armazenamos dados, protegemos dentro de meios comercialmente aceitáveis pela legislação atual para evitar perdas e roubos, bem como acesso, divulgação, cópia, uso ou modificação não autorizados.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Não compartilhamos informações de identificação pessoal publicamente ou com terceiros, exceto por determinação judicial.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Sobre nossas diretrizes:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Nosso aplicativo pode conter links para sites externos que não são operados por nós. Não nos responsabilizamos pelo conteúdo e práticas de sites de terceiros.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Você é livre para recusar a nossa solicitação de informações pessoais. O uso continuado do aplicativo será considerado como aceitação de nossa política de privacidade.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Se tiver alguma dúvida sobre como lidamos com dados do usuário e informações pessoais, entre em contato conosco através do e-mail: fernandocsdm@gmail.com.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Nossa política é atualizada de forma constante. O titular de dados ciente que o conteúdo desta Política de Privacidade pode ser alterado a critério do aplicativo, independente de aviso ou notificação.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'O aplicativo não se responsabiliza pelo uso incorreto ou inverídico de seus dados, ficando excluído de qualquer responsabilidade neste sentido.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Deleção de Contas e Informações Pessoais:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              'Você pode excluir sua conta e informações pessoais a qualquer momento. Basta acessar o menu do aplicativo e selecionar a opção "Deletar Conta". Será solicitado que você confirme a exclusão inserindo sua senha. Após a confirmação, faremos esforços razoáveis para excluir seus dados, sujeitos a obrigações legais de retenção de informações.',
              style: TextStyle(fontSize: 16),
            )
          ],
        ),
      ),
    );
  }
}
