# Recomendação Executiva — Alavancas de Receita (próximos 6 meses)

**Pergunta:** quais são as alavancas mais efetivas para aumentar a receita nos próximos 6 meses?

**Contexto dos dados:** o histórico vai até 29/08/2018. Uma janela de 6 meses a partir daí (set/2018–fev/2019) inclui a Black Friday de novembro — o evento sazonal mais previsível do calendário de varejo brasileiro.

Nenhum dos três impactos abaixo vem de um teste controlado (o dataset não tem isso). Cada um usa um número real medido como base e uma premissa de efeito assumida, deixada explícita — os cálculos completos, com as premissas editáveis, estão na seção "Estimativa de impacto (6 meses)" de `notebooks/analise_exploratoria.ipynb`.

## Alavanca 1 — Reativação de clientes (não fidelização de experiência)

**Dado:** 94,5% da receita vem de clientes que compraram uma única vez. A recompra em até 90 dias é de ~2% — e esse número **não muda** nem com atraso na entrega, nem com a satisfação do cliente (nota de review). A automação com IA (`notebooks/automacao_ia_sentimento.ipynb`) classificou o texto de ~41 mil reviews e confirmou que a nota numérica é uma proxy confiável de satisfação (75% de concordância com o sentimento do texto) — ou seja, a conclusão acima não é um artefato de má medição, é real. O problema não é qualidade pontual da experiência — é ausência de motivo para o cliente voltar a comprar na Olist especificamente.

**Ação compatível com 6 meses:** campanha segmentada de reativação (por categoria e valor gasto, não cupom genérico), com cashback ou cupom em até 90 dias da 1ª compra — não um programa de fidelidade de longo prazo, que normalmente leva mais de um ciclo de compra para mostrar resultado.

**Impacto estimado (6 meses): R$ 192.221**, assumindo +2 pontos percentuais na taxa de recompra sobre os 69.716 clientes de compra única dos últimos 12 meses do dataset.

**Limite:** é uma reativação pontual, não fidelização — retenção estrutural amadurece além de 6 meses e pede campanhas adicionais.

## Alavanca 2 — Prontidão operacional para a Black Friday

**Dado:** em 2017, o pico de vendas foi concentrado no dia 24/11 (Black Friday), com R$ 149,9 mil de receita — de 3 a 5x os dias ao redor, não o mês inteiro mais forte. Como os dados vão até agosto/2018, essa data cai dentro da janela de 6 meses à frente.

**Ação:** garantir estoque das categorias líderes de receita e capacidade operacional dos vendedores mais concentrados — os 10% que respondem por 67% da receita não podem travar nesse dia. Avaliar ampliar parcelamento no período, já que ticket médio escala com número de parcelas.

**Impacto estimado (no pico): R$ 129.838**, assumindo que 10% da venda do pico se perderia por ruptura de estoque/operação sem o preparo.

**Limite:** só há um ano completo de Black Friday nos dados (2017); é um padrão real, mas com uma única observação, e o % de perda evitada é premissa, não medição.

## Alavanca 3 — Promoção por quantidade (kits / desconto por volume)

**Dado:** o cliente já compra o mesmo produto em quantidade — o ticket sobe de R$ 130,57 (pedido de 1 item) para R$ 205,96 (2+ itens).

**Ação:** formalizar esse comportamento já existente com desconto por quantidade (ex.: leve 3, pague 2) nas categorias onde esse padrão é mais forte.

**Impacto estimado (6 meses): R$ 127.002**, assumindo 5% dos pedidos de 1 item (~5.615/mês) convertidos para 2+ itens com o incentivo.

**Limite:** é uma hipótese bem embasada nos dados, não uma causalidade comprovada — o dataset não tem teste de preço/elasticidade. Recomenda-se validar como teste controlado antes de escalar.

## Resumo para decisão

| Alavanca | Impacto estimado | Horizonte de retorno | Esforço | Evidência |
|---|---|---|---|---|
| Reativação | R$ 192.221 (6 meses) | Médio (meses) | Médio (campanha + CRM) | Muito forte, maior gap absoluto |
| Black Friday | R$ 129.838 (no pico) | Imediato (evento único, novembro) | Baixo (operacional) | Forte, mas 1 ano de histórico |
| Kits / quantidade | R$ 127.002 (6 meses) | Rápido (semanas) | Médio (precifição + teste) | Forte, correlacional |
| **Total** | **R$ 449.062** | | | |

**Uplift total estimado: +8,3%** sobre a receita real dos últimos 6 meses do dataset (R$ 5.393.645).

As três são complementares, não excludentes: reativação ataca a base de clientes que hoje só compra uma vez; Black Friday e kits atacam o ticket médio no curto prazo.
