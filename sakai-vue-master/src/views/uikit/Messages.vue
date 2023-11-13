<script setup>
import { FilterMatchMode } from 'primevue/api';
import { ref, onMounted, onBeforeMount } from 'vue';
import ProductService from '@/service/ProductService';
import { useToast } from 'primevue/usetoast';

const toast = useToast();

</script>

<script>
import axios from "axios";
import { ref } from 'vue';

//Constantes desiganadas para tanto las ventanas modales y las variables constantes para la actualización
const productDialog = ref(false);
const productDialogL = ref(false);
const dropTerreno = ref(false);
const updateTerreno = ref(false);
const updateLote = ref(false);
const numloteToUpdate = ref(false);
const numterrenoToUpdate = ref(false);

//Constantes las cuales sirven para obtener los datos de las ventanas modales en la operación actualización de datos 
const tipoG = ref(false);
const nL = ref(false);
const nT = ref(false);

//Aqui empiezan los métodos  para que se visualicen las ventanas con un botón

//método que abre la ventana modal para insertar un terreno
const openWindow = () => {
    productDialog.value = true;
};

//método que abre la ventana modal para insertar un lote de café
const openWindowL = () => {
    productDialogL.value = true;
};

//método que abre la ventana modal para actualizar un terreno
const openWindowUpdate = (row) => {
    //esta primeras CONSTANTES son aquellas donde por medio del ROW se obtienen los datos de la fila que se desea actualiza los datos de un TERRENO
    nT.value = row.nombret;
    console.log(nT.value);
    //sirve para que se visualice la ventana modal  
    updateTerreno.value = true;
    //aqui se guarda la PK de la fila(ROW) de la cual se desean actualizar los datos
    numterrenoToUpdate.value = row.numterreno;
    console.log('id terreno', numterrenoToUpdate.value);
};

//método que abre la ventana modal para actualizar un lote
const openWindowUpdateL = (row) => {
    //estas primeras CONSTANTES son aquellas donde por medio del ROW se obtienen los datos de la fila que se desea actualiza los datos de un lote
    tipoG.value = row.tipograno;
    nL.value = row.numterreno;
    //sirve para que se visualice la ventana modal  
    updateLote.value = true;
    //aqui se guarda la PK de la fila(ROW) de la cual se desean actualizar los datos
    numloteToUpdate.value = row.numlote;
    console.log('id lote', numloteToUpdate.value);
};
//Hasta aquí terminan los métodos de las ventanas modales 

export default {
    data() {
        return {
            terrenos: null,
            numTerre: null,
            numlote: nL,
            nombreTerreno: null,
            terreno: null,
            nombreUpdateTerreno: nT,
            numterreno: null,
            tipograno: tipoG,
            typeG: null,
            numberT: null,
        }

    },
    //En le mounted van aquellos metodos asincronos que se desea que se ejecuten en primera instancia 
    mounted() {
        //Llamamda a los métodos los cuales rellenan las tablas 
        this.getAllLotes();
        this.getAllTerrenos();
    },
    methods: {
        //Método correspondiente para la insercción de un terreno
        async realizarSolicitud() {
            if (this.nombreTerreno == null) { //validación del campo nulo
                this.$toast.add({ severity: 'warn', summary: '¡Favor de ingresar el nombre del terreno!', detail: '¡Ingresar el dato requerido!', life: 5000 });
            } else {
                try {
                    const response = await axios.post('http://localhost:3000/CreateTerreno', { //llamada a la REST API
                        nombret: this.nombreTerreno, // Usar el nombre del terreno ingresado por el usuario
                    });
                    console.log('Respuesta:', response.data);
                    this.$toast.add({ severity: 'success', summary: 'Terreno ingresado de manera exitosa', detail: '¡Todo bien!', life: 5000 });
                } catch (error) {
                    console.error('Error al hacer la solicitud POST:', error);
                    this.$toast.add({ severity: 'warn', summary: 'El terreno deseado no se ha podido registrar :( )', detail: '¡Probleas internos!', life: 5000 });
                }
            }
            //método con el cual se realiza la recarga de la pagina
            setTimeout(() => {
                location.reload();
            }, 2000); //dos segundos convertidos en milisegundos
        },
        //Método correspondiente para la insercción de un terreno
        async realizarSolicitudL() {
            if (this.typeG == null && this.numberL == null) { //validación del campo nulo
                console.log("oaaa");
                this.$toast.add({ severity: 'warn', summary: '¡Favor de ingresar el tipo de grano y el número del terreno!', detail: '¡Ingresar los datos requeridos!', life: 5000 });
            } else {
                try {
                    const response = await axios.post('http://localhost:3000/CreateLoteCafe', { //llamada a la REST API
                        tipograno: this.typeG,
                        numterreno: this.numberT,
                    });
                    console.log('Respuesta:', response.data);
                    this.$toast.add({ severity: 'success', summary: 'Lote ingresado de manera exitosa', detail: '¡Todo bien!', life: 5000 });
                } catch (error) {
                    console.error('Error al hacer la solicitud POST:', error);
                    this.$toast.add({ severity: 'warn', summary: 'El lote deseado no se ha podido registrar :( )', detail: '¡Probleas internos!', life: 5000 });
                }
            }
            //método con el cual se realiza la recarga de la pagina
            setTimeout(() => {
                location.reload();
            }, 2000); //dos segundos convertidos en milisegundos
        },
        async deleteTerreno(row) {
            try {
                const response = await axios.delete(`http://localhost:3000/DeleteTerreno/${row.numterreno}`);
                this.$toast.add({ severity: 'success', summary: 'Terreno eliminado de manera exitosa', detail: '¡Todo bien!', life: 1000 });
                console.log(response);
            } catch (error) {
                console.error('Error al hacer la solicitud DELETE:', error);
                this.$toast.add({ severity: 'warn', summary: 'El terreno deseado no se ha podido eliminar :( ', detail: '¡Probleas internos!', life: 1000 });
            }
            setTimeout(() => {
                location.reload();

            }, 1000);
        },
        async actualizarTerreno() {
            try {
                const response = await axios.put(`http://localhost:3000/updateTerreno/${numterrenoToUpdate.value}`, {
                    nombret: this.nombreUpdateTerreno,
                });
                this.$toast.add({ severity: 'success', summary: 'Terreno actualizado de manera exitosa', detail: '¡Todo bien!', life: 1000 });
                console.log('Respuesta de actualización:', response.data);
            } catch (error) {
                console.error('Error al hacer la solicitud PUT:', error);
                this.$toast.add({ severity: 'warn', summary: 'El terreno deseado no se ha podido Actualizar :( ', detail: '¡Probleas internos!', life: 1000 });
            }
            setTimeout(() => {
                location.reload();

            }, 1000);
        },
        async getAllLotes() {
            axios({
                method: 'GET',
                url: 'http://localhost:3000/obtLotesCafe',
                responseType: 'JSON'
            })
                .then((response) => {
                    this.tablaLotes = JSON.parse(response.data);
                    console.log(this.terrenos);
                });
        },
        async getAllTerrenos() {
            axios({
                method: 'GET',
                url: 'http://localhost:3000/terreno',
                responseType: 'JSON'
            })
                .then((response) => {
                    this.terrenos = JSON.parse(response.data);
                    console.log(this.terrenos);
                });
        },
        async deleteLote(row) {
            try {
                const response = await axios.delete(`http://localhost:3000/borrarLoteCafe/${row.numlote}`);
                this.$toast.add({ severity: 'success', summary: 'Lote eliminado de manera exitosa', detail: '¡Todo bien!', life: 1000 });
                console.log(response);
            } catch (error) {
                console.error('Error al hacer la solicitud DELETE:', error);
                this.$toast.add({ severity: 'warn', summary: 'Lote no se ha podido eliminar :( ', detail: '¡Probleas internos!', life: 1000 });
            }
            setTimeout(() => {
                location.reload();

            }, 1000);
        },
        async actualizarLote() {
            try {
                const response = await axios.put(`http://localhost:3000/actLoteCafe/${numloteToUpdate.value}`, {
                    nombret: this.tipograno,
                    nlte: this.numlote,
                });
                this.$toast.add({ severity: 'success', summary: 'Terreno actualizado de manera exitosa', detail: '¡Todo bien!', life: 1000 });
                console.log('Respuesta de actualización:', response.data);
            } catch (error) {
                console.error('Error al hacer la solicitud PUT:', error);
                this.$toast.add({ severity: 'warn', summary: 'El terreno deseado no se ha podido Actualizar :( ', detail: '¡Probleas internos!', life: 1000 });
            }
            setTimeout(() => {
                location.reload();

            }, 1000);
        },
    }
};

</script>

<template>
    <div class="grid">
        <div class="col-12">
            <div class="card">
                <h3>Sección de los terrenos</h3>
                <Toast />
                <Toolbar class="col-2">
                    <template v-slot:start && #body="slotProps">
                        <div class="my-2">
                            <Button label="Nuevo Terreno" icon="pi pi-plus" class="p-button-success mr-2"
                                @click="openWindow" />
                        </div>
                    </template>
                </Toolbar>
                <hr>
                <DataTable v-bind="value" :value="terrenos" class="p-datatable-gridlines" :paginator="true" :rows="5"
                    paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
                    :rowsPerPageOptions="[5, 10, 25]"
                    currentPageReportTemplate="Visualiando {last} de {totalRecords} terrenos." responsiveLayout="scroll">
                    <Column field="numterreno" header="Número de terreno" :sortable="true" style="width:50px"></Column>
                    <Column field="nombret" header="Nombre del terreno" style="width:370px"></Column>
                    <Column style="width:180px">
                        <template #header>
                            Acciones
                        </template>
                        <template #body="slotProps">
                            <Button icon="pi pi-pencil" type="button" class="p-button-success p-mr-2 p-mb-1"
                                @click="openWindowUpdate(slotProps.data)"></Button>
                            <Button icon="pi pi-trash" type="button" class="p-button-danger p-mb-1" @click="deleteTerreno(slotProps.data)"></Button>
                        </template>
                    </Column>
                </DataTable>
                <hr>
                <!-- PARTE DEL TEMPLETE DONDE EMPIEZA LA CODIFICACIÓN DE LA VISTA DE LOS LOTES DE CAFÉ  -->
                <div class="card">
                    <h3>Sección de los lotes del café</h3>

                    <Toast />
                    <Toolbar class="col-3">
                        <template v-slot:start && #body="slotProps">
                            <div class="my-2">
                                <Button label="Nuevo Lote de Café" icon="pi pi-plus" class="p-button-success mr-2"
                                    @click="openWindowL" />
                            </div>
                        </template>
                    </Toolbar>
                    <hr>
                    <DataTable :value="tablaLotes" class="p-datatable-gridlines" :paginator="true" :rows="5"
                        paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
                        :rowsPerPageOptions="[5, 10, 25]"
                        currentPageReportTemplate="Visualiando {last} de {totalRecords} lotes de café"
                        responsiveLayout="scroll">
                        <Column field="numlote" header="Codigo del lote" :sortable="true" style="width:50px"></Column>
                        <Column field="tipograno" header="Tipo de grano" style="width:370px"></Column>
                        <Column field="numterreno" header="Número de lote" style="width:370px"></Column>
                        <Column style="width:180px">
                            <template #header>
                                Acciones
                            </template>
                            <template #body="slotProps">
                                <Button icon="pi pi-pencil" type="button" class="p-button-success p-mr-2 p-mb-1" @click="openWindowUpdateL(slotProps.data)"></Button>
                                <Button icon="pi pi-trash" type="button" class="p-button-danger p-mb-1" @click="deleteLote(slotProps.data)"></Button>
                            </template>
                        </Column>
                    </DataTable>

                </div>

                <!--   VENTANAS MODALES  -->

                <!-- VENTANA MODAL PARA EL REGISTRAR UN TERRENO -->
                <Dialog v-model:visible="productDialog" :style="{ width: '500px' }"
                    header="Registrar el terreno dondé está el lote de café." modal="true" class="p-fluid">
                    <div class="field">
                        <label for="name">Nombre del terreno: </label>
                        <InputText id="name" v-model="nombreTerreno" />
                        <hr>
                        <Button label="Ingresar" class="p-button-raised p-button-success mr-2 mb-2"
                            @click="realizarSolicitud"></Button>
                    </div>
                </Dialog>
                <!-- VENTANA MODAL PARA EL REGISTRAR UN LODET DE CAFÉ -->
                <Dialog v-model:visible="productDialogL" :style="{ width: '500px' }"
                    header="Registrar los datos del lote de café." modal="true" class="p-fluid">
                    <div class="field">
                        <label for="name">Tipo de grano: </label>
                        <InputText id="tpg" v-model="typeG" />
                        <hr>
                        <label for="name">Número del terreno: </label>
                        <InputText id="tpg" v-model="numberT" />
                        <hr>
                        <Button label="Ingresar" class="p-button-raised p-button-success mr-2 mb-2"
                            @click="realizarSolicitudL"></Button>
                    </div>
                </Dialog>
                <!-- VENTANA MODAL PARA LA ELIMINACIÓN DE UN LOTE DE CAFÉ -->
                <Dialog v-model:visible="dropTerreno" :style="{ width: '500px' }"
                    header="¿Está seguro de eliminar el terreno seleccionado?" modal="true" class="p-fluid">
                    <div class="field" v>
                        <Button label="Eliminar Terreno" class="p-button-raised p-button-danger mr-2 mb-2"
                            @click="deleteTerreno(slotProps.data)" />
                    </div>
                </Dialog>
                <!--   VENTANAS MODALES PARA EL METODO UPDATE  -->
                <Dialog v-model:visible="updateTerreno" :style="{ width: '500px' }"
                    header="Actualizar los datos del terreno." modal="true" class="p-fluid">
                    <div class="field">
                        <label for="name">Nombre del terreno: </label>
                        <InputText id="name" v-model="nombreUpdateTerreno" />
                        <hr>
                        <Button label="Ingresar" class="p-button-raised p-button-success mr-2 mb-2"
                            @click="actualizarTerreno()"></Button>
                    </div>
                </Dialog>
                <!--   VENTANAS MODALES PARA EL METODO UPDATE  -->
                <Dialog v-model:visible="updateLote" :style="{ width: '500px' }"
                    header="Actualizar los datos del terreno." modal="true" class="p-fluid">
                    <div class="field">
                        <label for="name">Tipo de grano: </label>
                        <InputText id="name" v-model="tipograno" />
                        <hr>
                        <label for="name">Numero de lote: </label>
                        <InputText id="name" v-model="numlote" />
                        <hr>
                        <Button label="Ingresar" class="p-button-raised p-button-success mr-2 mb-2"
                            @click="actualizarLote()"></Button>
                    </div>
                </Dialog>
            </div>
        </div>
    </div>
</template>
