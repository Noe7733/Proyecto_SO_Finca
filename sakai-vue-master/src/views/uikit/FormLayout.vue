<script setup>
import { FilterMatchMode } from 'primevue/api';
import { ref, onMounted, onBeforeMount } from 'vue';
import ProductService from '@/service/ProductService';
import { useToast } from 'primevue/usetoast';

const toast = useToast();


</script>
<script>
import { ref } from 'vue';

import axios from "axios";
const productDialog = ref(false);
const idR = ref(false);
const nL = ref(false);

const openWindowActLote = (row) => {
    productDialog.value = true;
    idR.value = row.id;
    nL.value = row.lte;
};

export default {
    data() {
        return {
            idrecoleccion: idR,
            recoleccion: null,
            botonInhabilitado: false,
            numlote: nL,
            cla1: null,
            cla2: null,
            cla3: null,
            cla4: null,
        }
    },
    mounted() {

    },
    methods: {
        async AllRecolection() {
            axios({
                method: 'POST',
                url: 'http://localhost:3000/createAllRecolection',
                responseType: 'JSON'
            })
                .then((response) => {
                    this.$toast.add({ severity: 'success', summary: 'Lotes cargados de manera exitosa', detail: '¡Todo bien!', life: 5000 });
                });
        },
        async selectCrearRecoleccion() {
            axios({
                method: 'GET',
                url: 'http://localhost:3000/tablaPrincRecolec',
                responseType: 'JSON'
            })
                .then((response) => {
                    this.recoleccion = JSON.parse(response.data);
                    this.$toast.add({ severity: 'success', summary: 'Lotes cargados de manera exitosa', detail: '¡Todo bien!', life: 5000 });
                    console.log('Respuesta de la ventanaCreateRRRR: ', response.data);
                });
        },
        async actCantsCafe() {
            //console.log(this.numlote);
            try {
                const response = await axios.post(`http://localhost:3000/actCantCafe`, {
                    id: this.idrecoleccion,
                    lte: this.numlote,
                    cant1: this.cla1,
                    cant2: this.cla2,
                    cant3: this.cla3,
                    cant4: this.cla4,
                });
                this.$toast.add({ severity: 'success', summary: 'Recolección cargada de manera exitosa', detail: '¡Todo bien!', life: 1000 });
                console.log('Respuesta de actualización btn:', response.data);
            } catch (error) {
                console.error('Error al hacer la solicitud PUT:', error);
                this.$toast.add({ severity: 'warn', summary: 'Está recolección no se ha podido cargar:( ', detail: '¡Probleas internos!', life: 1000 });
            }
            setTimeout(() => {
                location.reload();

            }, 1000);
        },
        desactivarBoton() {
            this.botonInhabilitado = true;
        },
        async actSts(row){
            try {
                const response = await axios.put(`http://localhost:3000/actStsTrash/${row.id}`, {
                });
                this.$toast.add({ severity: 'success', summary: 'Truncado exitoso', detail: '¡Todo bien!', life: 1000 });
                console.log('Respuesta de actualización btn:', response.data);
            } catch (error) {
                console.error('Error al hacer la solicitud PUT:', error);
                this.$toast.add({ severity: 'warn', summary: 'Truncado fallido :( ', detail: '¡Probleas internos!', life: 1000 });
            }
            setTimeout(() => {
                location.reload();

            }, 1000);
        }
    }
};

</script>

<template>
    <div class="grid">
        <div class="col-12">
            <div class="card">
                <h3>Recolección</h3>
                <Toast />
                <Toolbar class="mb-4">
                    <template v-slot:start>
                        <div class="my-2">
                            <Button label="Cargar Lotes" icon="pi pi-plus" class="p-button-raised mr-2"
                                @click="AllRecolection() && desactivarBoton()" :disabled="botonInhabilitado" />
                        </div>
                        <div class="my-2">
                            <Button label="Iniciar recolección" icon="pi pi-plus" class="p-button-success mr-2"
                                @click="selectCrearRecoleccion()" />
                        </div>
                    </template>
                    <template v-slot:end>
                        <span class="p-input-icon-left mb-2">
                            <i class="pi pi-search" />
                            <InputText placeholder="Codigo de recolección" style="width: 100%" />
                        </span>
                    </template>
                </Toolbar>

                <DataTable v-bind="value" :value="recoleccion" class="p-datatable-gridlines" :paginator="true" :rows="10"
                    paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
                    :rowsPerPageOptions="[5, 10, 25]"
                    currentPageReportTemplate="Visualiando {last} de {totalRecords} lotes en recolección"
                    responsiveLayout="scroll">
                    <Column field="id" header="Codigo de recolección" :sortable="true" style="width:50px"></Column>
                    <Column field="lte" header="Número de Lote" style="width:50px"></Column>
                    <Column field="fce" header="Fecha" format="dd-MM-yyyy" style="width:100px"></Column>
                    <Column field="cla_1" header="Cafe verde" style="width:120px"></Column>
                    <Column field="cla_2" header="Cafe Maduro" style="width:120px"></Column>
                    <Column field="cla_3" header="Cafe sobremaduro" style="width:120px"></Column>
                    <Column field="cla_4" header="Cafe seco" style="width:120px"></Column>
                    <Column field="tot" header="Total de café" style="width:170px"></Column>
                    <Column field="sts" header="Status" style="width:170px"></Column>
                    <Column style="width:180px">
                        <template #header>
                            Acciones
                        </template>
                        <template #body="slotProps">
                            <Button icon="pi pi-pencil" type="button" class="p-button-success p-mr-2 p-mb-1"
                                @click="openWindowActLote(slotProps.data)"></Button>
                            <Button icon="pi pi-trash" type="button" class="p-button-danger p-mb-1" @click="actSts(slotProps.data)"></Button>
                        </template>
                    </Column>
                </DataTable>
                <Dialog v-model:visible="productDialog" :style="{ width: '940px' }" header="Iniciar proceso de recolección"
                    modal="true">
                    <div class="col-12">
                        <InputNumber id="tpg" v-model="cla1" placeholder="Cant. café verde:" />
                        <InputNumber id="tpg" v-model="cla2" placeholder="Cant.café maduro:" />
                        <InputNumber id="tpg" v-model="cla3" placeholder="Cant. café sobremaduro:" />
                        <InputNumber id="tpg" v-model="cla4" placeholder="Cant. de café seco:" />
                        <Button label="Cargar dato" icon="pi pi-pencil" type="button" class="p-button-success p-mr-2 p-mb-2"
                            @click="actCantsCafe()"></Button>
                    </div>
                </Dialog>
            </div>
        </div>
    </div>
</template>
