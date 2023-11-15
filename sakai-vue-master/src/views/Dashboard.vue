<script setup>
import { onMounted, reactive, ref, watch } from 'vue';
import ProductService from '@/service/ProductService';
import { useLayout } from '@/layout/composables/layout';

const { isDarkTheme } = useLayout();

const products = ref(null);

const lineOptions = ref(null);
const productService = new ProductService();

onMounted(() => {
    productService.getProductsSmall().then((data) => (products.value = data));
});

const formatCurrency = (value) => {
    return value.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
};
const applyLightTheme = () => {
    lineOptions.value = {
        plugins: {
            legend: {
                labels: {
                    color: '#495057'
                }
            }
        },
        scales: {
            x: {
                ticks: {
                    color: '#495057'
                },
                grid: {
                    color: '#ebedef'
                }
            },
            y: {
                ticks: {
                    color: '#495057'
                },
                grid: {
                    color: '#ebedef'
                }
            }
        }
    };
};

const applyDarkTheme = () => {
    lineOptions.value = {
        plugins: {
            legend: {
                labels: {
                    color: '#ebedef'
                }
            }
        },
        scales: {
            x: {
                ticks: {
                    color: '#ebedef'
                },
                grid: {
                    color: 'rgba(160, 167, 181, .3)'
                }
            },
            y: {
                ticks: {
                    color: '#ebedef'
                },
                grid: {
                    color: 'rgba(160, 167, 181, .3)'
                }
            }
        }
    };
};

watch(
    isDarkTheme,
    (val) => {
        if (val) {
            applyDarkTheme();
        } else {
            applyLightTheme();
        }
    },
    { immediate: true }
);
</script>

<template>
    <div class="container1">
        <h2>Sección de preguntas:</h2>
        <ul>
            <li v-for="question in displayedQuestions" :key="question">
                <button class="Buttonas" @click="sendMessage(question)">{{ question }} </button>
            </li>
        </ul>
    </div>


    <div v-if="chatVisible" class="chatbox-container">
        <div class="chatbox-container">
            <div class="chatbox-wrapper">
                <div class="container">
                    <div class="chatbot-name">
                        <h1>°-Chat Bot-°</h1>
                    </div>
                    <div class="messages-container" ref="messagesContainer">
                        <div class="messageBox" ref="messageBox">
                            <template v-for="(message, index) in messages" :key="index">
                                <div :class="message.from === 'user' ? 'messageFromUser' : 'messageFromChatGpt'">
                                    <div :class="message.from === 'user' ? 'userMessageWrapper' : 'chatGptMessageWrapper'">
                                        <div
                                            :class="message.from === 'user' ? 'userMessageContent' : 'chatGptMessageContent'">
                                            {{ message.data }}
                                        </div>
                                    </div>
                                </div>
                            </template>
                        </div>
                    </div>
                    <div class="inputContainer">
                        <input v-model="currentMessage" type="text" class="messageInput" placeholder="Preguntame algo..." />
                        <button @click="sendMessage(currentMessage)" class="askButton">Enviar</button>
                        <button @click="clearMessages" class="clearButton">Limpiar</button>
                    </div>

                </div>
            </div>
        </div>
    </div>
    <button @click="toggleChat" class="toggleChatButton">
        <i :class="chatVisible ? 'arrow-up-icon' : 'arrow-down-icon'"></i>
    </button>
</template>

<script>
import io from 'socket.io-client';

export default {
    data() {
        return {
            chatVisible: true,
            socket: null,
            messages: [],
            currentMessage: '',//se almacena el mensaje actual del user
            maxMessages: 70, // cantidad máxima de mensajes que se desea mostrar
            displayedQuestions: [ //manejo de preguntas visualizadas en el dash
                'Hola',
                '¿Cómo estás?',
                'Cómo se recolecta un lote de café?',
                'Cómo se despulpa un lote de café?',
                'Cómo se fermenta un lote de café?',
                'Cómo se lava un lote de café?',
                'Cómo se seca un lote de café?',
                'Qué es un lote de café?',
                'Cuáles son los procesos de los lotes de café?',
                'Cuál es el primer proceso de los lotes del café?',
                'Cuál es el segundo proceso de los lotes del café?',
                'Cuál es el tercer proceso de los lotes del café?',
                'Cuál es el cuarto proceso de los lotes del café?',
                'Cuál es el quinto proceso de los lotes del café?',
                'Donde se fermenta los lotes del café?',
                'Donde se secan los lotes el café?',
                'Cuántos tipos de cafe existen?',
                'Cual es el tipo de café mas utilizado en México?',
                'Cuál es la finalidad del sistema creado?',

            ],
            predefinedResponses: { //manejo de preguntas y respuestas
                'Hola': '¡Hola! ¿Cómo puedo ayudarte hoy?',
                'hola': '¡Hola! ¿Cómo puedo ayudarte hoy?',
                'holaa': '¡Hola! ¿Cómo puedo ayudarte hoy?',
                'ola': '¡Hola! ¿Cómo puedo ayudarte hoy?',
                '¿Cómo estás?': 'Estoy bien, gracias. ¿Y tú?',

                'Cómo se recolecta un lote de café?': 'Los lotes de cafe son recolectados de dos maneras, de manera manual y de manera automatizada (maquina), pero en este caso se hace automatizada',
                'Dime cómo se recolecta un lote de café': 'Los lotes de cafe son recolectados de dos maneras, de manera manual y de manera automatizada (maquina), pero en este caso se hace automatizada',
                'De qué manera se recolecta un lote de café?': 'Los lotes de cafe son recolectados de dos maneras, de manera manual y de manera automatizada (maquina), pero en este caso se hace automatizada',
                'Menciona cómo se recolecta un lote de café?': 'Los lotes de cafe son recolectados de dos maneras, de manera manual y de manera automatizada (maquina), pero en este caso se hace automatizada',

                'Cómo se despulpa un lote de café?': 'Comúnmente se realiza con una máquina despulpadora, implicará girar una manivela o realizar algún tipo de acción manual para romper la pulpa que rodea los granos, La pulpa se separará de los granos, y estos caerán en un recipiente debajo de la máquina',
                'De qué manera se despulpa un lote de café': 'Comúnmente se realiza con una máquina despulpadora, implicará girar una manivela o realizar algún tipo de acción manual para romper la pulpa que rodea los granos, La pulpa se separará de los granos, y estos caerán en un recipiente debajo de la máquina',
                'Dime cómo se despulpa un lote de café': 'Comúnmente se realiza con una máquina despulpadora, implicará girar una manivela o realizar algún tipo de acción manual para romper la pulpa que rodea los granos, La pulpa se separará de los granos, y estos caerán en un recipiente debajo de la máquina',
                'Menciona cómo se despulpa un lote de café': 'Comúnmente se realiza con una máquina despulpadora, implicará girar una manivela o realizar algún tipo de acción manual para romper la pulpa que rodea los granos, La pulpa se separará de los granos, y estos caerán en un recipiente debajo de la máquina',

                'Cómo se fermenta un lote de café?': 'Coloca los granos en tinajas o recipientes específicos para la fermentación. Estos recipientes pueden ser de plástico, concreto o cualquier material que sea fácil de limpiar y no afecte negativamente el sabor del café, se añade agua y se mantiene un control de temperatura.',
                'Dime cómo se fermenta un lote de café': 'Coloca los granos en tinajas o recipientes específicos para la fermentación. Estos recipientes pueden ser de plástico, concreto o cualquier material que sea fácil de limpiar y no afecte negativamente el sabor del café, se añade agua y se mantiene un control de temperatura.',
                'De qué manera se fermenta un lote de café': 'Coloca los granos en tinajas o recipientes específicos para la fermentación. Estos recipientes pueden ser de plástico, concreto o cualquier material que sea fácil de limpiar y no afecte negativamente el sabor del café, se añade agua y se mantiene un control de temperatura.',
                'Menciona cómo se fermenta un lote de café': 'Coloca los granos en tinajas o recipientes específicos para la fermentación. Estos recipientes pueden ser de plástico, concreto o cualquier material que sea fácil de limpiar y no afecte negativamente el sabor del café, se añade agua y se mantiene un control de temperatura.',


                'Cómo se lava un lote de café?': 'Transferimos los granos fermentados a los recipientes de lavado. Puedes utilizar cestas o coladores para facilitar este proceso, se llena los recipientes con agua limpia, se remueven los granos en el agua para eliminar restos de mucílago y otros residuos de la fermentación, después del lavado inicial, se drena el agua sucia y se rellena los recipientes con agua limpia para un segundo lavado',
                'Dime cómo se lava un lote de café': 'Transferimos los granos fermentados a los recipientes de lavado. Puedes utilizar cestas o coladores para facilitar este proceso, se llena los recipientes con agua limpia, se remueven los granos en el agua para eliminar restos de mucílago y otros residuos de la fermentación, después del lavado inicial, se drena el agua sucia y se rellena los recipientes con agua limpia para un segundo lavado',
                'De que manera se lava un lote de café': 'Transferimos los granos fermentados a los recipientes de lavado. Puedes utilizar cestas o coladores para facilitar este proceso, se llena los recipientes con agua limpia, se remueven los granos en el agua para eliminar restos de mucílago y otros residuos de la fermentación, después del lavado inicial, se drena el agua sucia y se rellena los recipientes con agua limpia para un segundo lavado',
                'Menciona cómo se lava un lote de café': 'Transferimos los granos fermentados a los recipientes de lavado. Puedes utilizar cestas o coladores para facilitar este proceso, se llena los recipientes con agua limpia, se remueven los granos en el agua para eliminar restos de mucílago y otros residuos de la fermentación, después del lavado inicial, se drena el agua sucia y se rellena los recipientes con agua limpia para un segundo lavado',


                'Cómo se seca un lote de café?': 'Extendemos uniformemente los granos de café sobre las camas de secado, se observa las condiciones climáticas. Si es posible, trata de secar los granos al sol. En caso de condiciones climáticas adversas, como lluvias, se pueden utilizar secadores mecánicos o techos para proteger los granos, ajustamos la disposición de los granos según las condiciones climáticas para evitar problemas de humedad, después de alcanzar el contenido de humedad deseado, almacenamos los granos en un lugar fresco y seco hasta que estén listos para molerlos.',
                'Dime cómo se seca un lote de café?': 'Extendemos uniformemente los granos de café sobre las camas de secado, se observa las condiciones climáticas. Si es posible, trata de secar los granos al sol. En caso de condiciones climáticas adversas, como lluvias, se pueden utilizar secadores mecánicos o techos para proteger los granos, ajustamos la disposición de los granos según las condiciones climáticas para evitar problemas de humedad, después de alcanzar el contenido de humedad deseado, almacenamos los granos en un lugar fresco y seco hasta que estén listos para molerlos.',
                'Menciona cómo se seca un lote de café?': 'Extendemos uniformemente los granos de café sobre las camas de secado, se observa las condiciones climáticas. Si es posible, trata de secar los granos al sol. En caso de condiciones climáticas adversas, como lluvias, se pueden utilizar secadores mecánicos o techos para proteger los granos, ajustamos la disposición de los granos según las condiciones climáticas para evitar problemas de humedad, después de alcanzar el contenido de humedad deseado, almacenamos los granos en un lugar fresco y seco hasta que estén listos para molerlos.',
                'De qué se seca un lote de café?': 'Extendemos uniformemente los granos de café sobre las camas de secado, se observa las condiciones climáticas. Si es posible, trata de secar los granos al sol. En caso de condiciones climáticas adversas, como lluvias, se pueden utilizar secadores mecánicos o techos para proteger los granos, ajustamos la disposición de los granos según las condiciones climáticas para evitar problemas de humedad, después de alcanzar el contenido de humedad deseado, almacenamos los granos en un lugar fresco y seco hasta que estén listos para molerlos.',


                'Qué es un lote de café?': 'un lote de café es una cantidad identificable de granos de café que  comparten características similares y que se gestionan y comercializan como una unidad en el mercado.',
                'Cuál es la definición de un lote de café?': 'un lote de café es una cantidad identificable de granos de café que  comparten características similares y que se gestionan y comercializan como una unidad en el mercado.',
                'Explícame qué significa un lote de café': 'un lote de café es una cantidad identificable de granos de café que  comparten características similares y que se gestionan y comercializan como una unidad en el mercado.',
                'Define el concepto de lote de café': 'un lote de café es una cantidad identificable de granos de café que  comparten características similares y que se gestionan y comercializan como una unidad en el mercado.',
                'Puedes describir lo que implica un lote de café?': 'un lote de café es una cantidad identificable de granos de café que  comparten características similares y que se gestionan y comercializan como una unidad en el mercado.',
                'A qué nos referimos con la expresión "lote de café"?': 'un lote de café es una cantidad identificable de granos de café que  comparten características similares y que se gestionan y comercializan como una unidad en el mercado.',
                'Explica el término "lote de café"': 'un lote de café es una cantidad identificable de granos de café que  comparten características similares y que se gestionan y comercializan como una unidad en el mercado.',

                'Cuáles son los procesos de los lotes de café?': 'Los procesos de los lotes de café son: Recolección, Despulpado, \n Fermentación, Lavado y Secado.',
                'Menciona los procesos de los lotes de café': 'Los procesos de los lotes de café son: Recolección, Despulpado, \n Fermentación, Lavado y Secado.',
                'Dime cualés son los procesos de los lotes de café': 'Los procesos de los lotes de café son: Recolección, Despulpado, \n Fermentación, Lavado y Secado.',
                'Qué procesos llevan los lotes de café?': 'Los procesos de los lotes de café son: Recolección, Despulpado, \n Fermentación, Lavado y Secado.',
                'Qué procesos se aplican a los lotes de café?': 'Los procesos de los lotes de café son: Recolección, Despulpado, \n Fermentación, Lavado y Secado.',


                'Cuál es el primer proceso de los lotes del café?': 'El primer proceso de los lotes de café es La Recolección.',
                'Menciona el primer proceso de los lotes del café': 'El primer proceso de los lotes de café es La Recolección.',
                'Dime el primer proceso de los lotes del café': 'El primer proceso de los lotes de café es La Recolección.',

                'Cuál es el segundo proceso de los lotes del café?': 'El segundo proceso de los lotes de café es El Despulpado.',
                'Dime el segundo proceso de los lotes del café': 'El segundo proceso de los lotes de café es El Despulpado.',
                'Menciona cuál es el segundo proceso de los lotes del café': 'El segundo proceso de los lotes de café es El Despulpado.',


                'Cuál es el tercer proceso de los lotes del café?': 'El tercer proceso de los lotes de café es La Fermentación',
                'Dime el tercer proceso de los lotes del café': 'El tercer proceso de los lotes de café es La Fermentación',
                'Menciona cuál es el tercer proceso de los lotes del café': 'El tercer proceso de los lotes de café es La Fermentación',


                'Cuál es el cuarto proceso de los lotes del café?': 'El cuarto proceso de los lotes de café es El Lavado',
                'Dime el cuarto proceso de los lotes del café': 'El cuarto proceso de los lotes de café es El Lavado',
                'Menciona cuál el cuarto proceso de los lotes del café?': 'El cuarto proceso de los lotes de café es El Lavado',


                'Cuál es el quinto proceso de los lotes del café?': 'El quinto proceso de los lotes de café es El Secado',
                'Dime el quinto proceso de los lotes del café?': 'El quinto proceso de los lotes de café es El Secado',
                'Menciona cuál es el quinto proceso de los lotes del café?': 'El quinto proceso de los lotes de café es El Secado',


                'Donde se fermenta los lotes del café?': 'El café se fermenta en tanques especializados para la fermentación',
                'En que lugar se fermentan los lotes del café?': 'El café se fermenta en tanques especializados para la  fermentación',
                'En qué lugares se lleva a cabo la fermentación de lotes de café?': 'El café se fermenta en tanques especializados para la  fermentación',

                'Donde se secan los lotes el café?': 'Los lotes de café se secan en cuartos especializados para el secado.',
                'En qué lugar se secan los lotes el café?': 'Los lotes de café se secan en cuartos especializados para el secado.',
                'En qué lugares se lleva a cabo el secado de lotes de café?': 'Los lotes de cafe se secan en cuartos especializados para el secado.',

                'Cuántos tipos de cafe existen?': 'Existen dos tipos de café, los cuales son: Café arábica, Café robusta.',
                'Cuáles son las diferentes clases de café?': 'Existen dos tipos de café, los cuales son: Café arábica, Café robusta.',
                'Cuántos tipos de granos de café existen?': 'Existen dos tipos de café, los cuales son: Café arábica, Café robusta.',

                'Cuál es el proposito de este sistema?': 'Administrar el control de los procesos que se aplican o implementan a los lotes de café, desde su recolección \n hasta el lavado del mismo.',
                'Cuál es la finalidad del sistema creado?': 'Administrar el control de los procesos que se aplican o implementan a los lotes de café, desde su recolección \n hasta el lavado del mismo.',
                'Para qué fue creado este sistema?': 'Administrar el control de los diferentes procesos que se aplican o implementan a los lotes de café, desde su recolección \n hasta el lavado del mismo.',
                'Para qué sirve esté sistema?': 'El control de los procesos que se aplican o implementan a los lotes de café, desde su recolección \n hasta el lavado del mismo.',


                'Cual es el tipo de café mas utilizado en México?': 'El tipo de café mas utilizado en méxico es el Café arábica.',
                'Dime cuál es  el tipo de cacaféfe mas utilizado en México?': 'El tipo de café mas utilizado en méxico es el Café arábica.',
                'Menciona el tipo de café mas utilizado en México?': 'El tipo de café mas utilizado en méxico es el Café arábica.',
                'En México que tipo de café se utiliza más?': 'El tipo de café mas utilizado en méxico es el Café arábica.',


                'Cual es tu nombre?': 'No tengo nombre, pro puedes llamarme Vicma',
                'Como te llamas?': 'No tengo nombre, pro puedes llamarme Vicma',
                'Tienes nombre?': 'No tengo nombre, pro puedes llamarme Vicma',

                '': '¡Estas mandando un mensaje vacío!, porfavor escribe una pregunta.',
                'Adios': '¡Hasta luego!, que tengas un gran día.',
                'adios': '¡Hasta luego!, que tengas un gran día.',
                'bay': '¡Hasta luego!, que tengas un gran día.',
                'hasta luego': '¡Hasta luego!, que tengas un gran día.',
                'bye': '¡Hasta luego!, que tengas un gran día.',
                'nos vemos': '¡Hasta luego!, que tengas un gran día.',
                'chao': '¡Hasta luego!, que tengas un gran día.',
            },

            defaultMessage: 'No entendí la pregunta. ¿Puedes reformularla?'

        };
    },
    mounted() {
        this.socket = io('http://localhost:3000');//se establece la conexion socket con el servidor
        this.socket.on('message', (message) => {
            this.handleMessage(message);
            this.scrollToBottom();
        });
    },
    methods: {
        toggleChat() {
            this.chatVisible = !this.chatVisible;
            if (this.chatVisible) {
                this.scrollToBottom(); // mensajes depplazados hacía arriba
            }
        },
        sendMessage(message) { //mandamos la pregunta al chat en un socket
            this.messages.push({ from: 'user', data: `Tú: ${message}` });
            this.socket.emit('message', message);
            this.handleMessage(message);
            this.currentMessage = '';
            this.scrollToBottom();
        },
        handleMessage(message) { //el chat contesta con  la respuesta en un socket
            const response = this.predefinedResponses[message] || this.defaultMessage;
            this.messages.push({ from: 'chatGpt', data: `MR. Coffe: ${response}` });
            this.socket.emit('message', `Chatbot: ${response}`);

            // Limitar la cantidad de mensajes
            if (this.messages.length > this.maxMessages) {
                this.messages.shift();
            }
        },
        scrollToBottom() {
            this.$nextTick(() => {
                const container = this.$refs.messagesContainer;
                container.scrollTop = container.scrollHeight;
            });
        },
        clearMessages() { //limpiar los mensajes del chat
            this.messages = [];
        },
    },
};
</script>

<style scoped>
.chat-controls {
    position: fixed;
    bottom: 30px;
    right: 40px;
    /* Ajusta el espacio entre el chat y el botón */
    z-index: 100;
}

.toggleChatButton {
    font-size: 1rem;
    padding: 8px 12px;
    background-color: #4caf50;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
}

.toggleChatButton:hover {
    filter: brightness(110%);
}

.arrow-up-icon::before {
    content: '↑';
}

.arrow-down-icon::before {
    content: '↓';
}

.chatbox-container {
    position: fixed;
    bottom: 30px;
    right: 30px;
    z-index: 99;
    /* Reduzco el índice de apilamiento para que el botón esté encima */
    transition: all 0.3s ease-in-out;
}

.chatbox-container.hidden {
    transform: translateY(100%);
}

.chatbox-wrapper {
    position: fixed;
    bottom: 10px;
    right: 10px;
    width: 25%;
    max-height: 75vh;
    overflow-y: auto;
}

.container {
    display: flex;
    flex-direction: column;
    height: 100%;
    background-color: rgba(255, 255, 255, 0.8);
    /* Color de fondo con opacidad */
}

.messageInput {
    flex: 1;
    padding: 7px;
    border: 1px solid #ccc;
    border-radius: 5px;
    margin-right: 10px;
    /* Añade un margen derecho al input */
}

.askButton {
    font-size: 1rem;
    padding: 8px 12px;
    background-color: #5eff00;
    /* Color de fondo del botón Send */
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
}

.clearButton {
    font-size: 1rem;
    padding: 8px 12px;
    background-color: #ff0000;
    /* Color de fondo del botón Clear */
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
}


.clearButton:hover {
    filter: brightness(110%);
    /* Cambia el brillo al pasar el ratón */
}

.clearButton {
    font-size: 1rem;
    padding: 8px 12px;
    background-color: #ff0000;
    /* Color de fondo del botón Clear */
    color: white;
    border: none;
    border-radius: 4px;
    margin-left: 10px;
    cursor: pointer;
}

.clearButton:hover {
    background-color: #ff3333;
    /* Cambia el color al pasar el ratón */
}

.messages-container {
    flex-grow: 1;
    display: flex;
    flex-direction: column-reverse;
    overflow-y: auto;
}

.messageBox {
    overflow-y: auto;
}

.userMessageWrapper {
    background-color: #69bde4;
    /* Fondo azul pastel para mensajes de usuario */
    border-radius: 5px;
    padding: 8px;
    margin: 5px;
}

.chatGptMessageWrapper {
    background-color: #363636;
    /* Fondo gris oscuro para mensajes de respuesta del chat */
    color: white;
    /* Texto blanco para contrastar */
    border-radius: 5px;
    padding: 8px;
    margin: 5px;
}

.inputContainer {
    display: flex;
    justify-content: space-between;
    padding: 10px;
    border-top: 1px solid #ccc;
    position: sticky;
    bottom: 0;
    background-color: rgba(255, 255, 255, 1.2);
    /* Color de fondo con opacidad */
}

.messageInput {
    flex: 1;
    padding: 7px;
    border: 1px solid #ccc;
    border-radius: 5px;
}
</style>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Roboto:wght@400;500&display=swap');

@import url('https://fonts.googleapis.com/css2?family=Roboto:wght@400;500&display=swap');

.chatbot-name {
    text-align: center;
    padding: 15px;
    background: linear-gradient(45deg, #71d6c2, #4643d1);
    /* Efecto de color neón */
}

.chatbot-name h1 {
    margin: 0;
    font-size: 1.5rem;
    color: white;
    text-shadow: 2px 2px 4px rgba(44, 40, 40, 0.5);
    /* Sombra de texto */
}

.chatbox-container {
    position: fixed;
    bottom: 30px;
    right: 30px;
    z-index: 100;
}

.chatbox-wrapper {
    border: 1.5px solid rgb(80, 219, 215);
    /* Borde de color neón */
    border-radius: 10px;
    overflow: hidden;
    box-shadow: 0 0 20px rgba(0, 0, 0, 0.1);
}

.container {
    width: 380px;
    height: 500px;
    background-color: rgb(245, 238, 238);
    border-radius: 5px;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    font-family: 'Roboto', sans-serif;

}

.inputContainer {
    display: flex;
    align-items: flex-end;
    /* Posiciona el contenido al final del eje vertical */
}

.messageInput {
    flex: 1;
    padding: 7px;
    border: 1px solid #ccc;
    border-radius: 5px;
}

.askButton {
    font-size: 1.2rem;
    text-shadow: 2px 2px 4px rgba(14, 13, 13, 0.911);
    padding: 8px 10px;
    background: linear-gradient(45deg, #80eb42, #47e947);
    color: rgb(255, 254, 254);
    border: none;
    border-radius: 4px;
    cursor: pointer;

}

.askButton:hover {
    background: linear-gradient(45deg, #22ddb8, #0066ff);
}

.Buttonas {
    font-size: 1.2rem;
    text-shadow: 2px 2px 4px rgba(5, 5, 5, 0.911);
    padding: 5px 8px;
    background-color: rgba(255, 255, 255, 0.5);
    color: rgb(255, 254, 254);
    border: none;
    border-radius: 4px;
    cursor: pointer;

}

.Buttonas:hover {
    background: linear-gradient(45deg, #22dd6a, #0066ff);
}
</style>